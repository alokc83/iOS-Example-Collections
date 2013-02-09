/*
 *  Go4Singleton.h
 *  Singleton
 *
 *  Created by Carlo Chung on 6/10/10.
 *  Copyright 2010 Carlo Chung. All rights reserved.
 *
 */

class Singleton 
{
  
public:
  static Singleton *Instance();
  
protected:
  Singleton();
  
private:
  static Singleton *_instance;
  
};
