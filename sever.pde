//server
import processing.net.*;
final boolean SERVER = true;
final boolean CLIENT = false;

Server server;
int port = 20000;

PFont font;

//gamecontroll
int frame = 0;
int MaxFrame = 500;
int HP_server = 5;
int HP_client = 5;
boolean gameover_server = false;
boolean gameover_client = false;

//client-information
float y_player_client = 0.0f;
boolean push_B = false;
boolean push_A = false;

//bullet
int sum_bullet = 10000;
int count_bullet_server = 0;
int count_bullet_client = 0;
boolean destroy_server[] = new boolean[sum_bullet];
boolean destroy_client[] = new boolean[sum_bullet];

class Player
{
  float x_player;
  float y_player;
  float width_player;
  float height_player;
  
  Player()
  {
    x_player = 0.0f;
    y_player = height / 2.0f;
    width_player = 20.0f;
    height_player = 100.0f;
  }
  
  void Move(float y, boolean player)
  {
    y_player = y;
    
    if(player)//server
    {
      x_player = 10.0f;
      fill(0, 0, 100);
      rect(x_player, y_player, width_player, height_player);
    }
    else//client
    {
      x_player = width - 10.0f; 
      fill(100, 0, 0);
      rect(x_player, y_player, width_player, height_player);
    }    
  }
}

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

class Neutral
{
  float x_neutral;
  float y_neutral;
  float width_neutral;
  float height_neutral;
  
  Neutral()
  {
    x_neutral = 1500/2.0;
    y_neutral = 1000/2.0;
    width_neutral = 10.0f;
    height_neutral = 100.0f;
  }
  
  void Move(float difference, float speed)
  {
    float angle = (float)frame / (float)MaxFrame * 360.0;
    float rad = angle / 180.0 * (float)Math.PI;
    y_neutral =  450.0 * (float)Math.sin(speed * (rad + difference)) + 500.0;
    
    fill(50, 0, 50);
    rect(x_neutral, y_neutral, width_neutral, height_neutral);
  }
}
    

Player player_server = new Player();
Player player_client = new Player();
Bullet bullet_server[] = new Bullet[sum_bullet];
Bullet bullet_client[] = new Bullet[sum_bullet];
Neutral neutral_1 = new Neutral();
Neutral neutral_2 = new Neutral();

void setup()
{
  server = new Server(this, port);
  
  rectMode(CENTER);
  ellipseMode(CENTER);
  size(1500, 1000);
  colorMode(RGB, 100);
  noStroke();
  
  font = createFont("Arial", 100);
  textFont(font);
  textAlign(CENTER, CENTER);
  
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
    
    Client c = server.available();
    if(c != null)
    {
      String msg = c.readStringUntil('\n');
      if(msg != null)
      {
        String[] data = splitTokens(msg);
        y_player_client = float(data[0]);
        push_B = boolean(data[1]);
      }
    }
    
    countBullet(push_A, push_B);
   
    //bullet-server
    for(int i = 1;i <= count_bullet_server;i++)
    {
      if(!destroy_server[i-1])
      {
        bullet_server[i-1].Move();
        bullet_server[i-1].Collision(i-1);
        bullet_server[i-1].Collision_player(i-1, player_client.x_player, player_client.y_player, player_client.width_player, player_client.height_player);
        bullet_server[i-1].Collision_neutral(i-1, neutral_1.x_neutral, neutral_1.y_neutral, neutral_1.width_neutral, neutral_1.height_neutral);
        bullet_server[i-1].Collision_neutral(i-1, neutral_2.x_neutral, neutral_2.y_neutral, neutral_2.width_neutral, neutral_2.height_neutral);
      }
    }
    
    //bullet-client
    for(int i = 1;i <= count_bullet_client;i++)
    {
      if(!destroy_client[i-1])
      {
        bullet_client[i-1].Move();
        bullet_client[i-1].Collision(i-1);
        bullet_client[i-1].Collision_player(i-1, player_server.x_player, player_server.y_player, player_server.width_player, player_server.height_player);
        bullet_client[i-1].Collision_neutral(i-1, neutral_1.x_neutral, neutral_1.y_neutral, neutral_1.width_neutral, neutral_1.height_neutral);
        bullet_client[i-1].Collision_neutral(i-1, neutral_2.x_neutral, neutral_2.y_neutral, neutral_2.width_neutral, neutral_2.height_neutral);
      }
    }
    
    //player-server
    player_server.Move(mouseY, SERVER);
    
    //player-client
    player_client.Move(y_player_client, CLIENT);   
      
    //neutral
    neutral_1.Move(0.0, 1.0);
    neutral_2.Move((float)Math.PI, 2.0);
    sendAllData();
    
    //text
    String str = HP_server + "-" + HP_client;
    fill(0);
    text(str, width/2, 100);
    
    push_A = false;
    push_B = false;
    
    if(frame <= MaxFrame)
    {
      frame++;
    }
    else
    {
      frame = 0;
    }
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

void sendAllData()
{
  String msg = player_server.y_player + " " ;                                              //player
  msg += neutral_1.y_neutral + " " + neutral_2.y_neutral + " ";                            //neutral
  msg += HP_server + " " + HP_client + " " + gameover_server + " " + gameover_client + " ";//gamecontroll
  msg += push_A + " ";
  msg += "\n";
  server.write(msg);
}

void keyPressed()
{
  if(key == 'a')
  {
    push_A = true;
  }
}

void countBullet(boolean push_A, boolean push_B)
{
  if(push_A)
  {
    if(count_bullet_server < sum_bullet)
    {
      count_bullet_server++;
      bullet_server[count_bullet_server - 1].Start(player_server.y_player);
    }
  }
  if(push_B)
  {
    if(count_bullet_client < sum_bullet)
    {
      count_bullet_client++;
      bullet_client[count_bullet_client - 1].Start(player_client.y_player);
    }
  }
}
