//
//  Sorter.h
//  Sorter
//
//  Created by Amit Sachdeva on 17/7/18.
//  Copyright © 2018 Amit Sachdeva. All rights reserved.
//

#ifndef Sorter_h
#define Sorter_h

#include <stdio.h>
#include "MovieStruct.h"

struct MovieStruct* SortElements(struct MovieStruct *array, int size);
struct MovieStruct* MovieStructInit(const char* title,int titleLength,int rating, const char* imageUrl,int imageUrlLength);

#endif /* Sorter_h */
