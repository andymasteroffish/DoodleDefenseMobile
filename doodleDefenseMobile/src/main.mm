#include "testApp.h"
#include "ofMain.h"

int main(){
	ofSetupOpenGL(1024,768, OF_FULLSCREEN);			// <-------- setup the GL context
	ofRunApp(new testApp);
}


void testApp::setBackerNames(){
    
    int i=0;
    
    //24 $5 backers
    backerNames[i++] = "andre cardozo"; //the e should be é
    backerNames[i++] = "Isaac Lee Morris";
    backerNames[i++] = "Rahil";
    backerNames[i++] = "john s.";
    backerNames[i++] = "Eric S. Rozek";
    backerNames[i++] = "Dr. Muhammad Ame";
    backerNames[i++] = "Andrew Hamilton";
    backerNames[i++] = "Jonathan Busby";
    backerNames[i++] = "Steve Skura";
    backerNames[i++] = "Seth McCauley";
    
    backerNames[i++] = "Tami Evnin";
    backerNames[i++] = "MrEragon";
    backerNames[i++] = "Escaton";
    backerNames[i++] = "Jim Powell";
    backerNames[i++] = "John O'Neil";
    backerNames[i++] = "Frankie Spankie";
    backerNames[i++] = "Tim van der Nagel";
    backerNames[i++] = "Lorenzo Orselli";
    backerNames[i++] = "Jess Haskins";
    backerNames[i++] = "jim babb";
    
    backerNames[i++] = "Aubrey Foulk";
    backerNames[i++] = "Eric Oestrich";
    backerNames[i++] = "Victor Kim";
    backerNames[i++] = "The Ground Floor Gallery";
    
    //32 $20 backers
    backerNames[i++] = "George Dolbier";
    backerNames[i++] = "Nicolas Cinquegrani";
    backerNames[i++] = "Paul Ping Christopher Kohler";
    backerNames[i++] = "Robear Yang";
    backerNames[i++] = "Falco";
    backerNames[i++] = "Helenka Casler";
    backerNames[i++] = "Victoria Setian";
    backerNames[i++] = "Ta'Ding";
    backerNames[i++] = "Critical Mass";
    backerNames[i++] = "N.E.W.";
    
    backerNames[i++] = "Claudio Carbone";
    backerNames[i++] = "Per Hedbor";
    backerNames[i++] = "Andre Kishimoto";
    backerNames[i++] = "Nicolas";
    backerNames[i++] = "Frederico Afrange de Andrade";
    backerNames[i++] = "Miles Matton";
    backerNames[i++] = "Jane \"Will High Five Until You Are Comfortable\" Friedhoff";
    backerNames[i++] = "Maikel Lobbezoo";
    backerNames[i++] = "Haitham";
    backerNames[i++] = "Simon Bachelier";
    
    backerNames[i++] = "Sam Robinson";
    backerNames[i++] = "Mike Fish";
    backerNames[i++] = "Daniel P. Shaefer";
    backerNames[i++] = "Survy";
    backerNames[i++] = "Aketzu";
    backerNames[i++] = "Zack Sheppard";
    backerNames[i++] = "Sarah Friedhoff";
    backerNames[i++] = "Olaf Hallan Graven";
    backerNames[i++] = "TongYifan";
    backerNames[i++] = "Matt Plasek";
    
    backerNames[i++] = "Matt Radford";
    backerNames[i++] = "o. groon";
    
    
    //23 $40 backers
    backerNames[i++] = "Kenya Mizzell";
    backerNames[i++] = "Scott Morrison";
    backerNames[i++] = "Mark Kriegsman";
    backerNames[i++] = "Michael Johas Teener";
    backerNames[i++] = "Ariel Benzakein";
    backerNames[i++] = "Sue Watkins";
    backerNames[i++] = "Colleen Macklin";
    backerNames[i++] = "Michael Kwan";
    backerNames[i++] = "Michael Galluzzo";
    backerNames[i++] = "NY Coopers";
    
    backerNames[i++] = "Fred Emmott";
    backerNames[i++] = "@rsmoz";
    backerNames[i++] = "Riley Mills";
    backerNames[i++] = "Aviva Wallace";
    backerNames[i++] = "Amanda Jeffrey";
    backerNames[i++] = "Oliver Peltier";
    backerNames[i++] = "Josh";
    backerNames[i++] = "Coby Randquist";
    backerNames[i++] = "Erik W. B.";
    backerNames[i++] = "Caitlin Casiello";
    
    backerNames[i++] = "Skwashua";
    backerNames[i++] = "Jimmi Friborg";
    backerNames[i++] = "kate watkins";
    
    //2 $50 backers
    backerNames[i++] = "Chris Lohmann";
    backerNames[i++] = "Ezra Schrage";
    
    //3 $70 backers
    backerNames[i++] = "Roger 'Rahjur' Altizer";
    backerNames[i++] = "Matt Wang";
    backerNames[i++] = "joshua keys";
    
    
    //2 $100 backers
    backerNames[i++] = "Barn Cleave";
    backerNames[i++] = "Kevin Bruckert";
    
    //odd sound credit
    backerNames[i++] = "freesound.org/people/stijn/";
    
    
    
}