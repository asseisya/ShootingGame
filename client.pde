//client
import processing.net.*;
final boolean SERVER = true;
final boolean CLIENT = false;

Client client;
String severAdder = "127.0.0.1";
int port = 20000;

PFont font;

//gamecontroll
int HP_server = 5;                                    //recieved
int HP_client = 5;                                    //recieved
boolean gameover_server = false;                      //recieved
boolean gameover_client = false;                      //recieved
boolean push_A = false;
boolean push_B = false;

//player
float width_player = 20.0f;
float height_player = 100.0f;

//player-server
float x_player_server = 10.0f;
float y_player_server;                                //recieved

//player-client
float x_player_client;
float y_player_client;

//bullet
int sum_bullet = 10000;
boolean destroy_server[] = new boolean[sum_bullet];   //recieved
boolean destroy_client[] = new boolean[sum_bullet];   //recieved
int count_bullet_server = 0;                          //recieved
int count_bullet_client = 0;                          //recieved

//neutral_1
float x_neutral_1 = 1500/2.0;
float y_neutral_1 = 1000/2.0;                         //recieved
float width_neutral_1 = 10.0f;
float height_neutral_1 = 100.0f;

//neutral_2
float x_neutral_2 = 1500/2.0;
float y_neutral_2 = 1000/2.0;                         //recieved
float width_neutral_2 = 10.0f;
float height_neutral_2 = 100.0f;

class Bullet
{
  float r;
  float x_bullet;
  float y_bullet;
  float speed;
  boolean player;
  
  Bullet(boolean player_inf)
  {
    r = 10.0f;
    x_bullet = 0.0f;
    y_bullet = 0.0f;
    speed = 10.0f;
    player = player_inf;   
  }
  
  void Move()
  {
    if(player)//server
    {
      x_bullet += speed;
      fill(0, 0, 100);
      ellipse(x_bullet, y_bullet, 2 * r, 2 * r);
    }
    else//client
    {
      x_bullet -=speed;
      fill(100, 0, 0);
      ellipse(x_bullet, y_bullet, 2 * r, 2 * r);
    }
  }
  
  void Start(float y_player)
  {
    if(player)//server
    {
      x_bullet = 10.0f;
      y_bullet = y_player;
    }
    else//client
    {
      x_bullet = width - 10.0f;
      y_bullet = y_player;
    }
  }
  
  void Collision(int i)
  {
    if(x_bullet + r > width || x_bullet - r < 0)
    {
      if(player)//server
      {
        destroy_server[i] = true;
      }
      else      //client
      {
        destroy_client[i] = true;
      }
    }
  }
  
  void Collision_player(int i, float x_player, float y_player, float width_player, float height_player)
  {
    if(y_player - height_player/2.0 <= y_bullet && y_bullet <= y_player + height_player/2.0)//right - left
    {
      if(abs(x_player - x_bullet) < r + width_player/2.0)
      {
        if(player)//server
        {
          destroy_server[i] = true;
          HP_client--;
          if(HP_client == 0)gameover_client = true;
        }
        else      //client
        {
          destroy_client[i] = true;
          HP_server--;
          if(HP_server == 0)gameover_server = true;
        }
      }
    }
    else if(x_player - width_player/2.0 <= x_bullet && x_bullet <= x_player + width_player/2.0)//above - below
    {
      if(abs(y_player - y_bullet) < r + height_player/2.0)
      {
        if(player)//server
        {
          destroy_server[i] = true;
          HP_client--;
          if(HP_client == 0)gameover_client = true;
        }
        else      //client
        {
          destroy_client[i] = true;
          HP_server--;
          if(HP_server == 0)gameover_server = true;
        }
      }
    }
  }
  
  void Collision_neutral(int i, float x_neutral, float y_neutral, float width_neutral, float height_neutral)
  {
    if(y_neutral - height_neutral/2.0 <= y_bullet && y_bullet <= y_neutral + height_neutral/2.0)//right - left
    {
      if(abs(x_neutral - x_bullet) < r + width_neutral/2.0)
      {
        if(player)//server
        {
          destroy_server[i] = true;
        }
        else      //client
        {
          destroy_client[i] = true;
        }
      }
    }
    
    if(x_neutral - width_neutral/2.0 <= x_bullet && x_bullet <= x_neutral + width_neutral/2.0)//above - below
    {
      if(abs(y_neutral - y_bullet) < r + height_neutral/2.0)
      {
        if(player)//server
        {
          destroy_server[i] = true;
        }
        else      //client
        {
          destroy_client[i] = true;
        }
      }
    }
  }  
}

Bullet bullet_server[] = new Bullet[sum_bullet];
Bullet bullet_client[] = new Bullet[sum_bullet];

void setup()
{
  client = new Client(this, severAdder, port);
  
  rectMode(CENTER);
  ellipseMode(CENTER);
  size(1500, 1000);
  colorMode(RGB ,100);
  noStroke();
  
  font = createFont("Arial", 100);
  textFont(font);
  textAlign(CENTER, CENTER);
  
  x_player_client = width - width_player/2.0;
  
  for(int i = 0;i < sum_bullet;i++)
  {
    bullet_server[i] = new Bullet(SERVER);
    bullet_client[i] = new Bullet(CLIENT);
    destroy_server[i] = false;
    destroy_client[i] = false;
  }
}

void draw()
{
  if(!gameover_server && !gameover_client)
  {
    background(100);
    y_player_client = mouseY;
    
    countBullet(push_A, push_B);
    
    //player-server
    fill(0, 0, 100);
    rect(x_player_server, y_player_server, width_player, height_player);
    
    //player-client
    fill(100, 0, 0);
    rect(x_player_client, y_player_client, width_player, height_player);
    
    //bullet-server
    for(int i = 1;i <= count_bullet_server;i++)
    {
      if(!destroy_server[i-1])
      {
        bullet_server[i-1].Move();
        bullet_server[i-1].Collision(i-1);
        bullet_server[i-1].Collision_player(i-1, x_player_client, y_player_client, width_player, height_player);
        bullet_server[i-1].Collision_neutral(i-1, x_neutral_1, y_neutral_1, width_neutral_1, height_neutral_1);
        bullet_server[i-1].Collision_neutral(i-1, x_neutral_2, y_neutral_2, width_neutral_2, height_neutral_2);
      }
    }
    
    //bullet-client
    for(int i = 1;i <= count_bullet_client;i++)
    {
      if(!destroy_client[i-1])
      {
        bullet_client[i-1].Move();
        bullet_client[i-1].Collision(i-1);
        bullet_client[i-1].Collision_player(i-1, x_player_server, y_player_server, width_player, height_player);
        bullet_client[i-1].Collision_neutral(i-1, x_neutral_1, y_neutral_1, width_neutral_1, height_neutral_1);
        bullet_client[i-1].Collision_neutral(i-1, x_neutral_2, y_neutral_2, width_neutral_2, height_neutral_2);
      }
    }
    
    //neutral_1
    fill(50, 0, 50);
    rect(x_neutral_1, y_neutral_1, width_neutral_1, height_neutral_1);
    
    //neutral_2
    fill(50, 0, 50);
    rect(x_neutral_1, y_neutral_2, width_neutral_1, height_neutral_1);
    
    //text
    String str = HP_server + "-" + HP_client;
    fill(0);
    text(str, width/2, 100);
    
    String msg = y_player_client + " " + push_B + " " + "\n";
    client.write(msg);
    
    push_A = false;
    push_B = false;
  }
  else if(gameover_server)
  {
    background(100);
    fill(0);
    text("Client Win!!", width/2, height/2);
  }
  else if(gameover_client)
  {
    background(100);
    fill(0);
    text("Server Win!!", width/2, height/2);
  }
  else if(count_bullet_server > sum_bullet && count_bullet_client > sum_bullet)
  {
    background(100);
    fill(0);
    text("Draw", width/2, height/2);
  }
}

void clientEvent(Client c)
{
  String msg = c.readStringUntil('\n');
  if(msg != null)
  {
    String[] data = splitTokens(msg);
    y_player_server = float(data[0]);
    y_neutral_1 = float(data[1]);
    y_neutral_2 = float(data[2]);
    HP_server = int(data[3]);
    HP_client = int(data[4]);
    gameover_server = boolean(data[5]);
    gameover_client = boolean(data[6]);
    push_A = boolean(data[7]);
  }
}

void keyPressed()
{
  if(key == 'b')
  {
    push_B = true;
  }
}

void countBullet(boolean push_A, boolean push_B)
{
  if(push_A)
  {
    if(count_bullet_server < sum_bullet)
    {
      count_bullet_server++;
      bullet_server[count_bullet_server - 1].Start(y_player_server);
    }
  }
  if(push_B)
  {
    if(count_bullet_client < sum_bullet)
    {
      count_bullet_client++;
      bullet_client[count_bullet_client - 1].Start(y_player_client);
    }
  }
}
