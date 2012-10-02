//
//  tile.h
//  emptyExample
//
//  Created by Andy Wallace on 11/21/11.
//  Copyright (c) 2011 AndyMakes. All rights reserved.
//

#ifndef emptyExample_tile_h
#define emptyExample_tile_h

#include "ofMain.h"

class tile{
public:
    int x,y;    //location of the tile
    
    //pathfinding distance values
    int f;  //total of the distance to get to this tile and estimated distance to goal
    int g;  //movement cost to get to this tile from starting point
    int h;  //estimated distance to goal
    
    tile * parent;  //pointer to the parent tile
    
    int depth;      //how far this tile is from the origin. This is only used when trying to grow out from the foes current posiiton to reach a standard path
    
    tile(){
        //nothign needs to be here
    }
    
    tile(int _x, int _y){
        x=_x;
        y=_y;
    }
    
    
};



#endif
