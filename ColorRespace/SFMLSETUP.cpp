
// SFMLSETUP.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <iostream>
#include <string>
#include <SFML/Graphics.hpp>
#include <SFML/System.hpp>
#include <SFML/Config.hpp>
#include <SFML/Audio.hpp>
#include <map>
int main()
{



    int boxsize = 400;
    sf::RenderWindow window(sf::VideoMode(1920, 1080), "Game");
    sf::Shader shader;
    if (!shader.loadFromFile("shader.glsl", sf::Shader::Fragment))
    {
        // error...
    }
    int width = 1920;
    int height = 1080;

    sf::Vector3i ChannelRange = sf::Vector3i(2,2,2);
    bool HSLmode = false;
    sf::Font font;
    if (!font.loadFromFile("Arial.ttf"))
    {
        // error...
    }
    sf::Text precision;
    precision.setFont(font);
    precision.setCharacterSize(24);
    std::string path;
    //std::getline(std::cin, path);

    sf::RectangleShape shape;
    shape.setSize(sf::Vector2f(boxsize, boxsize));
    std::getline(std::cin, path);
    if (path[0] == '\"') {
        path.erase(path.begin());
        path.erase(path.end() - 1);
    }

    sf::Texture myTexture;
    if (!(myTexture.loadFromFile(path))) {
        std::cout << "invalid path\n";
        exit(-1);
    }
    
    bool State = false;
    


    while (window.isOpen()) {
        sf::Event event;
        while (window.pollEvent(event)) {
            if (event.type == sf::Event::Closed) {
                window.close();
            }
            if (event.type == sf::Event::MouseWheelMoved) {



                if (sf::Keyboard::isKeyPressed(sf::Keyboard::R)) {

                    if (event.mouseWheel.delta > 0 || ChannelRange.x > 0) {
                        ChannelRange.x += event.mouseWheel.delta;
                    }

                  
                }
                if (sf::Keyboard::isKeyPressed(sf::Keyboard::G)) {
                    if (event.mouseWheel.delta > 0 || ChannelRange.y > 0) {
                        ChannelRange.y += event.mouseWheel.delta;
                    }
                }
                if (sf::Keyboard::isKeyPressed(sf::Keyboard::B)) {
                    if (event.mouseWheel.delta > 0 || ChannelRange.z > 0) {
                        ChannelRange.z += event.mouseWheel.delta;
                    }
                }

               
            }
        }

        

        

        ChannelRange.x %= 16;
        ChannelRange.y %= 16;
        ChannelRange.z %= 16;
        ChannelRange = sf::Vector3i(abs(ChannelRange.x), abs(ChannelRange.y), abs(ChannelRange.z));
        shader.setUniform("channelRange", ChannelRange);
        shader.setUniform("Use_HSL", HSLmode);
        sf::Sprite sprite;
        sprite.setTexture(myTexture);
        shape.setTexture(&myTexture);
        //sprite.setScale((float)width / myTexture.getSize().x, (float)height / myTexture.getSize().y);
        
       

        std::string InfoText = "RGB:";
        if (HSLmode) {
            InfoText = "HSL:";
        }
        
        precision.setString(InfoText + std::to_string(ChannelRange.x + 1) + ":" + std::to_string(ChannelRange.y + 1) + ":" + std::to_string(ChannelRange.z + 1));

        window.clear();

        // put game logic here and rendering code here
        
        shader.setUniform("DrawColorSpace", 0);
        window.draw(sprite, &shader);

   
        shape.setPosition(sf::Vector2f(width - boxsize, boxsize));
        shader.setUniform("DrawColorSpace", 1);
        window.draw(shape, &shader);
        shape.setPosition(sf::Vector2f(width - boxsize, 0));
        shader.setUniform("DrawColorSpace", 2);
        window.draw(shape, &shader);
        window.draw(precision);
    
        window.display();


       

       
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Space)) {


            if (!State) {
                HSLmode = !HSLmode;
            }

            State = true;
        }
        else {

       


            State = false;
        }


    }
}