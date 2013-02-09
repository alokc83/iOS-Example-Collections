/*
 *  Go4Singleton.cpp
 *  Singleton
 *
 *  Created by Carlo Chung on 6/10/10.
 *  Copyright 2010 Carlo Chung. All rights reserved.
 *
 */

#include "Go4Singleton.h"

Singleton *Singleton::_instance = 0;

Singleton *Singleton::Instance()
{
  if (_instance == 0)
  {
    _instance = new Singleton;
  }
  
  return _instance;
}


Singleton::Singleton()
{
  
}