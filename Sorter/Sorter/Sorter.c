//
//  Sorter.c
//  Sorter
//
//  Created by Amit Sachdeva on 17/7/18.
//  Copyright © 2018 Amit Sachdeva. All rights reserved.
//

#include <stdlib.h>
#include <string.h>
#include "Sorter.h"

int compare(const void *s1, const void *s2)
{
    struct MovieStruct *e1 = (struct MovieStruct *)s1;
    struct MovieStruct *e2 = (struct MovieStruct *)s2;
    return e1->rating - e2->rating ;
}

struct MovieStruct* SortElements(struct MovieStruct *array, int size)
{
    qsort(array, size, sizeof(struct MovieStruct), compare);
    return array;
}

struct MovieStruct* MovieStructInit(const char* title,int titleLength,int rating, const char* imageUrl,int imageUrlLength) {
    struct MovieStruct *newStruct = malloc(sizeof(struct MovieStruct));
    newStruct->title = (char *) malloc(titleLength * sizeof(char));
    newStruct->imageUrl = (char *) malloc(imageUrlLength * sizeof(char));
    strcpy(newStruct->title, title);
    newStruct->rating = rating;
    strcpy(newStruct->imageUrl, imageUrl);

    return newStruct;
}

