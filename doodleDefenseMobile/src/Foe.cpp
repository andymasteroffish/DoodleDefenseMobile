//
//  Foe.cpp
//  opencvExample
//
//  Created by Andy Wallace on 11/24/11.
//  Copyright (c) 2011 AndyMakes. All rights reserved.
//

#include "Foe.h"

//------------------------------------------------------------
void Foe::setup(float x, float y, float _goalX, float _goalY, float _fieldScale, int _fieldW, int _fieldH, int level, bool _retina){
    p.pos.x=x;
    p.pos.y=y;
    fieldScale=_fieldScale;
    fieldW=_fieldW;
    fieldH=_fieldH;
    
    retina = _retina;
    
    //get read to handle movement
    moveParticle.setInitialCondition(0,0,0,0);
    moveParticle.bFixed=true;   //move particle is locked in place so that it only pulls the foe towards it
    moveAtractionIncrease=0.02;
    nextNodeRad=20;
    
    //set pathfinding distance values
    horzDist=10;
    diagDist=14;
    
    //set the goal THIS IS IN FIELD UNITS
    goalX=_goalX/fieldScale;
    goalY=_goalY/fieldScale;
    
    if (goalX>65)   horizontalGoal = true;
    else            horizontalGoal = false;
    
    //set it that it has not gone through any tiles yet
    justBacktracked=false;
    maxSpeed=1;
    reexploredTileSpeedBonus = 0.004;
    for (int c=0; c<fieldW; c++)
        for (int r=0; r<fieldH; r++)
            tilesExplored[c][r]=false;
    
    
    //game state info
    dead=false;
    reachedTheEnd=false;
    endBolt=false;
    pathFound = true;
    freezeTimer=0;
    
    //default game vals
    fullHP=50+ 50*level;
    speed=0.15;//0.1;
    inkVal=6;
    damageToPlayer=1;
    
    //set type specific game values that might change the above values
    typeSetup(level);
    hp=fullHP;  //give it the full HP set in typeSetup
    
    //setting how to move through the images
    curPicFrame=0;
    timeBetweenFrames=0.1;  //how many seconds to wait between frames
    nextFrameTime=ofGetElapsedTimef()+timeBetweenFrames;
    
    //turning the picture
    displayAngle=0;
    turnSpeed=0.1;
    
}

//------------------------------------------------------------
void Foe::setPics(ofImage stroke[], ofImage fill[]){
    for (int i=0; i<NUM_FOE_FRAMES; i++){
        picStroke[i]=&stroke[i];
        picFill[i]=&fill[i];
    }
}

//------------------------------------------------------------
void Foe::update(){
    
    if (! *paused){
        bool frozen=false;
        if (freezeTimer>0 && freezeTimer%2==0)  frozen=true;
        if (route.size()>2 && !frozen){
            
            //reset the particle
            p.resetForce();
            
            //atract the controler to the next node
            float atraction=moveAtraction;
            //foes need ot move fast across the screen on retina devices
            p.addAttractionForce(moveParticle, p.pos.distance(moveParticle.pos)*1.5, atraction*(1+retina));
            
            moveAtraction+= moveAtractionIncrease;
            
            //dampen and update the particle
            p.addDampingForce();
            p.update();
        }
        
        //see if we're ready to go to the next node
        if (p.pos.distance(moveParticle.pos)<nextNodeRad){
            setNextNode();
        }
        
        //if we're at the end, bolt off screen
        if (ofDist(p.pos.x,p.pos.y,goalX*fieldScale,goalY*fieldScale)<15){
            //reachedTheEnd=true;
            endBolt=true;
            //set the move particle just off screen
            
            //check which gate this foe is using
            if (goalX>goalY)
                moveParticle.pos.x+=10;
            else
                moveParticle.pos.y+=10;
        }
        
        //reduce freezeTimer. if it is above 0 the foe is frozen
        freezeTimer--;
    }
    
    //moving the foe off screen if it has reached the end
    if (endBolt){
        //reset the particle
        p.resetForce();
        
        //atract the controler to the next node
        float atraction=moveAtraction*5;
        p.addAttractionForce(moveParticle, p.pos.distance(moveParticle.pos)*1.5, atraction);
        
        moveAtraction+=moveAtractionIncrease;
        
        //dampen and update the particle
        p.addDampingForce();
        p.update();
        
        //if we've reach the move particle, the foe is done
        if ( (goalX>goalY && p.pos.x>moveParticle.pos.x) || 
            (goalY>goalX && p.pos.y>moveParticle.pos.y) ) {
            reachedTheEnd=true;
        }
        
    }
    
    //test if the foes is dead
    if (hp<=0)  dead=true;
    
    //move the display angle toward the direction the particle is moving
    float angle=atan2(moveParticle.pos.y-p.pos.y, moveParticle.pos.x-p.pos.x);
    displayAngle = (1-turnSpeed)*displayAngle + turnSpeed*angle;
    
    //set which frame to display if enough time has passed to change the frame
    if (ofGetElapsedTimef()>nextFrameTime){
        nextFrameTime=ofGetElapsedTimef()+timeBetweenFrames;
        //advance the frame, wrapping it around if it reached the end
        curPicFrame= (curPicFrame+1)%NUM_FOE_FRAMES;
        
    }
    
}

//------------------------------------------------------------
void Foe::standardDraw(){
    
    ofFill();
    
    
    //have it flash if there is no path
    if (showPath){
        drawExplored();
    }
    
    //draw the outline and the fill
    ofPushMatrix();
    ofTranslate(p.pos.x, p.pos.y);
    ofRotate(ofRadToDeg(displayAngle)-90); //the foes are drawn facing up, so they need to be rotated 90 degrees
    //ofScale(0.15,0.15);
    
    //set the level of fill based on the health
    ofSetColor(255,255,255, ofMap(hp, 0,fullHP, 0,255) );
    picFill[curPicFrame]->draw(0,0);
    ofSetColor(0);
    if (freezeTimer>0)  ofSetColor(12,61,168);
    picStroke[curPicFrame]->draw(0,0);
    ofPopMatrix();
    
}

//------------------------------------------------------------
void Foe::drawDebug(){
    //draw the path if one was found
    //if (*showAllInfo){
        
    ofPushMatrix();
    ofScale(fieldScale,fieldScale); 
    
    if (showAllInfo){
        ofSetColor(0,255,0);
        ofSetLineWidth(2);
        if (route.size()>3){
            for (int i=0; i<route.size()-1; i++)
                ofLine(route[i]->x, route[i]->y,route[i+1]->x, route[i+1]->y);
        }
        //animate a ball moving along the path
        if (route.size()>0){
            ofCircle(route[ofGetFrameNum()%route.size()]->x, route[ofGetFrameNum()%route.size()]->y, 1);
        }
    }
    
    if (!pathFound){
        //otherwise draw the area explored
        ofSetColor(255,0,0,20);
        for (int i=0; i<closedList.size()-1; i++)
            ofRect(closedList[i]->x,closedList[i]->y,2,2);
        //ofLine(route[i]->x, route[i]->y,route[i+1]->x, route[i+1]->y);
    }
    
    ofPopMatrix();
    
    ofSetHexColor(0x52E2F2);
    moveParticle.draw();
    //}
}

//------------------------------------------------------------
//draws the area that was explored when no path was found.
void Foe::drawExplored(){
    float alpha = MAX(0, ofMap( sin(ofGetElapsedTimef()*2), -1, 1, -5, 20));
    //if (ofGetFrameNum()/6%5>1){
        ofSetColor(220,35,130,alpha);
        ofPushMatrix();
        ofScale(fieldScale,fieldScale);
        for (int i=0; i<closedList.size()-1; i++)
            ofRect(closedList[i]->x,closedList[i]->y,2,2);
        ofPopMatrix();
    //}
    
}

//------------------------------------------------------------
//after we have all the points, start the route
void Foe::setNextNode(){
    //advance the nextNode
    nextNode=MAX(nextNode-1,0);
    
    //get the field position of the node
    int tileX= MIN( fieldW-1, MAX(0, route[nextNode]->x));
    int tileY= MIN( fieldH-1, MAX(0, route[nextNode]->y));
    
    //set the particle position
    moveParticle.pos.x=tileX*fieldScale;
    moveParticle.pos.y=tileY*fieldScale;
    
    moveAtraction=speed;
    
    //see if the foe has already been here
    if (tilesExplored[tileX][tileY]){
        speed+=reexploredTileSpeedBonus;
        speed=MIN(maxSpeed,speed);
        justBacktracked=true;
    }
    
    //set this tile as explored
    tilesExplored[tileX][tileY]=true;
    
}

//------------------------------------------------------------
//make sure stealth foes don't check this
bool Foe::checkExistingRoute(ofPoint (&routeGrid)[FIELD_W][FIELD_H]){
    showPath=false;
    
    //the stealth foe should not worry about this
    if (type=="stealth")
        return false;
    
    //reset the  particle
    p.vel.set(0,0);
    p.frc.set(0,0);
    
    //do some error checking
    if (routeGrid[goalX][goalY].x == -2 && routeGrid[goalX][goalY].y == -2){
        cout<<"we got big problems: the foe's goal wasn't on the route map"<<endl;
        return false;
    }
    
    
    //see if the foe is already on the natural path
    int foeFieldX = p.pos.x/fieldScale;
    int foeFieldY = p.pos.y/fieldScale;
    
    ofPoint connectingPos;  //if the foe is on or near the path, this is the point where the path meets the foe
    vector<tile *> pathToRoute; //YOU NEED TO DELETE EVERYTHING IN HERE WHEN IT'S DONE
    
    //cout<<"foe fieldX: "<<foeFieldX<<"  foe field y: "<<foeFieldY<<endl;
    //cout<<"next node: "<<nextNode<<"   route size: "<<route.size()<<endl;
    if ( routeGrid[foeFieldX][foeFieldY].x != -2 && routeGrid[foeFieldX][foeFieldY].y != -2){
        //cout<<"shit my dad, I'm already on the path"<<endl;
        connectingPos.set(foeFieldX, foeFieldY);
        //path to Route will be empty because the foe is already on the route
    }else{
        //cout<<"Oh fuck, I'm not on the path. Try growing out to meet the path "<<endl;
        pathToRoute = checkProximityToExistingRoute(routeGrid);
        if (pathToRoute.size()==0){
            //cout<<"couldn't grow out"<<endl;
            return false;
        }
        //cout<<"Shit yes  could grow out. path size: "<<pathToRoute.size()<<endl;
        
        //if we get here, a viable connecting point was found
        connectingPos.set( pathToRoute[0]->x, pathToRoute[0]->y);
    }
    
    //the foe's next position is on the path!
    clearPathfindingLists();    //get rid of the path finding data
    
    //add to the positions on the route lists in reverse order, starting at the goal
    //tile newTile(goalX,goalY);
    tile * goalTile = new tile(goalX,goalY);
    //adding to clsoed list first and not route directly, because data in closed list gets deleted, route does not. No memory leaks, please
    closedList.push_back(goalTile);     
    
    //go through adding each tile until we get to the one the foe is on now
    ofPoint nextPos = routeGrid[goalX][goalY];
    while (connectingPos!=nextPos){
        //add this loaction to the list
        tile * newTile = new tile((int)nextPos.x, (int)nextPos.y);
        closedList.push_back(newTile);
        //advance to the next one
        nextPos= routeGrid[newTile->x][newTile->y];
    }
    
    //now add all of these points to the route vector
    route.clear();
    for (int i=0; i<closedList.size(); i++){
        route.push_back(closedList[i]);
    }
    
    //if there was an aditional path to get to the route, add those now too
    for (int i=0; i<pathToRoute.size(); i++){
        route.push_back(pathToRoute[i]);
    }
    
    //reset the next node to start from the beginning
    nextNode=route.size();
    setNextNode();

    pathFound = true;
    return true;
}

//THIS WILL NEED A LIST OF POINTS IN BETWEEN THE FOE AND THE CONENCTING POINT TO BE ADDED AT THE END
vector<tile *> Foe::checkProximityToExistingRoute(ofPoint (&routeGrid)[FIELD_W][FIELD_H]){
    ofPoint connectingPoint(-1,-1); //assume that no connecting point will be found
    
    int distToCheck = 8;    //how far the route can be from the foe and still be found
    
    vector<tile *> unexplored;     
    vector<tile *> explored;
    
    //get the starting point
    int foeFieldX = p.pos.x/fieldScale;
    int foeFieldY = p.pos.y/fieldScale;
    
    
    //add that point to the unexplored list
    tile * startTile = new tile(foeFieldX, foeFieldY);  //this tile ahs no parent
    startTile->depth = 0;
    unexplored.push_back(startTile);
    
    bool pathFoundToRoute = false;
    //keep searching until we run out of tiles or find a path
    while (!pathFoundToRoute && unexplored.size()>0) {
        
        tile * current=unexplored[0];
        //move this pointer to the explroed list now
        explored.push_back(current);
        unexplored.erase(unexplored.begin());
        
        //if this tile is on the route, we're done
        if (routeGrid[current->x][current->y].x != -2 && routeGrid[current->x][current->y].y != -2){
            pathFoundToRoute = true;
        }
        
        //if this is tile is as far as we're willing to search, don't explore further from here
        bool tooFar = false;
        if (current->depth>= distToCheck){
            tooFar = true;
        }
        
        //if not, keep expanding the search
        if (!pathFoundToRoute && !tooFar){
            //check the 8 tiles around this one
            for (int x=-1; x<=1; x++){
                for (int y=-1; y<=1; y++){
                    int xPos=current->x+x;
                    int yPos=current->y+y;
                    //make sure this tile is not the current one or off the grid
                    if (xPos>=0 && xPos<fieldW && yPos>=0 && yPos<fieldH && (x!=0 || y!=0) ){
                        int pixelPos=yPos*fieldW+xPos;   
                        //check if the tile is impassible
                        if (wallPixels[pixelPos]==255){     //255 is a clear tile that can be moved through
                            //don't add any tile that is adjacent to a wall
                            //this is to help keep the path a little less hugging one wall
                            bool nextToWall=false;
                            for (int x2=-1; x2<=1; x2++){
                                for (int y2=-1; y2<=1; y2++){
                                    int pixelPos2=(yPos+y2)*fieldW+(xPos+x2);
                                    if (wallPixels[pixelPos2]==0)
                                        nextToWall=true;
                                }
                            }
                            
                            if (!nextToWall){
                                //check that the tile is not already in the explroed or unexplroed lists
                                bool inList=false;  //assume it isn't
                                for (int i=0; i<unexplored.size(); i++){
                                    if (unexplored[i]->x==xPos && unexplored[i]->y==yPos)
                                        inList=true;
                                }
                                for (int i=0; i<explored.size(); i++){
                                    if (explored[i]->x==xPos && explored[i]->y==yPos)
                                        inList=true;
                                }
                                
                                //if it isn't in any one of those lists, make a tile for it and add it to unexplroed
                                if (!inList){
                                    tile * newTile = new tile(xPos,yPos);
                                    newTile->parent = current;
                                    newTile->depth = current->depth+1;
                                    unexplored.push_back(newTile);
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    //if a path was found, add those points so the foe can reach the standard route
    //this will start on the last thing added to the explored vector
    //tile * path = explored[explored.size()-1];
    vector<tile *> pathToRoute;
    
    if (pathFoundToRoute){
        pathToRoute.push_back( explored[explored.size()-1] );   //add the connecting pos
        while (pathToRoute[pathToRoute.size()-1]->x != foeFieldX && pathToRoute[pathToRoute.size()-1]->y != foeFieldY){
            pathToRoute.push_back( pathToRoute[pathToRoute.size()-1]->parent );
            
        }
        
        //set the connecting point to be useful
        connectingPoint.set(pathToRoute[0]->x, pathToRoute[0]->y);
        //cout<<"connecting point: "<<connectingPoint.x<<","<<connectingPoint.y<<endl;
    }
    
    //clear the vectors
    while (unexplored.size()){
        delete unexplored[0];
        unexplored.erase(unexplored.begin());
    }
    
    int killNum = 0;
    while (explored.size() > pathToRoute.size()){
        //make sure we don't delet part of the path to the standard route
        bool partOfPath = false;
        for (int i=0; i<pathToRoute.size(); i++){
            if (explored[killNum] == pathToRoute[i]){
                partOfPath = true;
                killNum++;
            }
        }
        
        if (!partOfPath){
            delete explored[killNum];
            explored.erase(explored.begin()+killNum);
        }
    }
    
    return pathToRoute;
}

//------------------------------------------------------------
//attempt to find a path
void Foe::standardFindPath(){
    //cout<<"doin' it MY WAY"<<endl;
    
    showPath=false;
    
    int startX=p.pos.x/fieldScale;
    int startY=p.pos.y/fieldScale;
    
    startX=MAX(0,MIN(startX,fieldW-1));
    startY=MAX(0,MIN(startY,fieldH-1));
    
    //clear out the vectors
    clearPathfindingLists();
    
    //add the start tile to the openList
    tile * start = new tile();
    start->x=startX;
    start->y=startY;
    start->g=0;
    start->h=getDistToGoal(start->x,start->y);
    start->f= start->g+start->h;
    openList.push_back(start);
    
    //tile * parent=t;
    bool goalFound=false;
    bool doneSearching=false;
    while(!doneSearching){
        
        //find the lowest F value in the open list
        int lowestID=0;
        for (int i=0; i<openList.size(); i++){
            if(openList[i]->f <= openList[lowestID]->f)
                lowestID=i;
        }
        
        //move this tile to the closed list
        closedList.push_back(openList[lowestID]);
        //remove it from the open list
        openList.erase(openList.begin()+lowestID);
        
        //explore this tile
        tile * current=closedList[closedList.size()-1];
        
        //if this was the goal tile, we're done
        if(current->x==goalX && current->y==goalY){
            goalFound=true;
            doneSearching=true;
        }
        
        //check the 8 tiles aorund this one
        for (int x=-1; x<=1; x++){
            for (int y=-1; y<=1; y++){
                int xPos=current->x+x;
                int yPos=current->y+y;
                //make sure this tile is not the current one or off the grid
                if (xPos>=0 && xPos<fieldW && yPos>=0 && yPos<fieldH && (x!=0 || y!=0) ){
                    int pixelPos=yPos*fieldW+xPos;   //MAKE A FUNCTION FOR THIS
                    //check if the tile is impassible
                    if (wallPixels[pixelPos]==255){
                        //don't add any tile that is adjacent to a wall
                        //this is to help keep the path a little less hugging one wall
                        bool nextToWall=false;
                        for (int x2=-1; x2<=1; x2++){
                            for (int y2=-1; y2<=1; y2++){
                                int pixelPos2=(yPos+y2)*fieldW+(xPos+x2);
                                if (wallPixels[pixelPos2]==0)
                                    nextToWall=true;
                            }
                        }
                        
                        if (!nextToWall){
                            //check that the tile is not in the closed list
                            bool inClosedList=false;  //assume it isn't
                            for (int c=0; c<closedList.size(); c++){
                                if (closedList[c]->x==xPos && closedList[c]->y==yPos)
                                    inClosedList=true;
                            }
                            if (!inClosedList){
                                //check to see if it is already in the open list
                                int openListID=-1;
                                for (int o=0; o<openList.size(); o++){
                                    if (openList[o]->x==xPos && openList[o]->y==yPos)
                                        openListID=o;
                                }
                                
                                //add it to the open list if it isn't already there
                                if (openListID==-1){
                                    tile * t = new tile();
                                    t->x=xPos;
                                    t->y=yPos;
                                    if (y==0 || x==0) t->g=current->g+horzDist;
                                    else              t->g=current->g+diagDist;
                                    t->h=getDistToGoal(xPos, yPos);
                                    t->f=t->g+t->h;
                                    t->parent=current;
                                    openList.push_back(t);
                                    //if we just added the goal to the open list, we're done
                                    //THIS WILL NOT ALWAYS BE AS ACURATE AS WAITING UNTIL THE GOAL IS ADDED TO THE CLOSED LIST
                                    //BUT IT IS FASTER
                                    if (t->x==goalX && t->y==goalY){
                                        doneSearching=true;
                                        goalFound=true;
                                        //add it to closed list so it will be added to the route
                                        closedList.push_back(t);
                                        //remove it from the open list
                                        openList.erase(openList.begin()+openList.size()-1);
                                    }
                                }else{
                                    //if it is there see if this path is faster
                                    int newG;       //measure distance to the tile based on g
                                    if (y==0 || x==0) newG=current->g+horzDist;
                                    else              newG=current->g+diagDist;
                                    if (newG<openList[openListID]->g){
                                        openList[openListID]->g=newG;   //set g to be the new, shorter distance
                                        openList[openListID]->f=newG+openList[openListID]->h;   //reset the f value for this tile
                                        openList[openListID]->parent=current;   //change the parent
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        //if we're out of tiles, there is no path
        if (openList.size()==0)
            doneSearching=true;//testing
        
    }
    
    //if it found a path, add it to the route
    if (goalFound){
        //the memory positions pointed to in route may have already been destroyed
        route.clear();  //first, clear the old route
        
        pathFound=true;
        //start with the goal and work backwards
        route.push_back(closedList[closedList.size()-1]);
        while(! (route[route.size()-1]->x==startX && route[route.size()-1]->y==startY)){
            route.push_back(route[route.size()-1]->parent);
        }
        //reset the next node to start from the beginning
        nextNode=route.size()-1;
        setNextNode();
    }else{
        pathFound=false;
        showPath=true;
        route.clear();  //remove whatever confused route it may have stubled upon while searching
    }

}

//--------------------------------------------------------------
//goes thorugh the route the foe has now and returns true if none of the tiles on the route are obstructed or next to an obstructions
bool Foe::checkRouteForObstruction(){
    showPath=false;
    
    //stealth foes can ignore this
    if (type=="stealth")
        return true;
    
    //error checking 
    if (nextNode>route.size()){
        cout<<"We got problems: nextNode was larger than route.size()"<<endl;
        return false;
    }
    
    for (int i=0; i<nextNode; i++){
        int pixelPos=route[i]->y*fieldW+route[i]->x; 
        
        //check if the tile is impassible
        if (wallPixels[pixelPos]==255){
            //return false if this tile is clear, but an adjacent one isn't
            for (int x2=-1; x2<=1; x2++){
                for (int y2=-1; y2<=1; y2++){
                    int pixelPos2=(route[i]->y+y2)*fieldW+(route[i]->x+x2);
                    if (wallPixels[pixelPos2]==0)
                        return false;   //this tile is impassible because there is a tile next to it that is a wall
                }
            }
        }else{
            return false;   //this tile itself has become impassible
        }
    }
    
    
    return true;
}

//--------------------------------------------------------------
int Foe::getDistToGoal(int x, int y){ 
    return ( abs(x-goalX)*horzDist + abs(y-goalY)*horzDist);
}

//--------------------------------------------------------------
void Foe::clearPathfindingLists(){
    while(openList.size()>0){
		delete openList[0];
		openList.erase(openList.begin());
	}
    while(closedList.size()>0){
        delete closedList[0];
		closedList.erase(closedList.begin());
	}
    
    
    
}

//--------------------------------------------------------------
void Foe::freeze(int time){ 
    freezeTimer=time;
}