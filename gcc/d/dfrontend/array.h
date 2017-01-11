/* Copyright (c) 2011-2014 by Digital Mars
 * All Rights Reserved, written by Walter Bright
 * http://www.digitalmars.com
 * Distributed under the Boost Software License, Version 1.0.
 * (See accompanying file LICENSE or copy at http://www.boost.org/LICENSE_1_0.txt)
 * https://github.com/dlang/dmd/blob/master/src/root/array.h
 */

#ifndef ARRAY_H
#define ARRAY_H

#if __DMC__
#pragma once
#endif

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "object.h"
#include "rmem.h"

template <typename TYPE>
struct Array
{
    d_size_t dim;
    TYPE *data;

  private:
    Array(const Array&);

    d_size_t allocdim;
    #define SMALLARRAYCAP       1
    TYPE smallarray[SMALLARRAYCAP];    // inline storage for small arrays

  public:
    Array()
    {
        data = SMALLARRAYCAP ? &smallarray[0] : NULL;
        dim = 0;
        allocdim = SMALLARRAYCAP;
    }

    ~Array()
    {
        if (data != &smallarray[0])
            mem.xfree(data);
    }

    char *toChars()
    {
        const char **buf = (const char **)mem.xmalloc(dim * sizeof(const char *));
        d_size_t len = 2;
        for (d_size_t u = 0; u < dim; u++)
        {
            buf[u] = ((RootObject *)data[u])->toChars();
            len += strlen(buf[u]) + 1;
        }
        char *str = (char *)mem.xmalloc(len);

        str[0] = '[';
        char *p = str + 1;
        for (d_size_t u = 0; u < dim; u++)
        {
            if (u)
                *p++ = ',';
            len = strlen(buf[u]);
            memcpy(p,buf[u],len);
            p += len;
        }
        *p++ = ']';
        *p = 0;
        mem.xfree(buf);
        return str;
    }

    void reserve(d_size_t nentries)
    {
        //printf("Array::reserve: dim = %d, allocdim = %d, nentries = %d\n", (int)dim, (int)allocdim, (int)nentries);
        if (allocdim - dim < nentries)
        {
            if (allocdim == 0)
            {   // Not properly initialized, someone memset it to zero
                if (nentries <= SMALLARRAYCAP)
                {   allocdim = SMALLARRAYCAP;
                    data = SMALLARRAYCAP ? &smallarray[0] : NULL;
                }
                else
                {   allocdim = nentries;
                    data = (TYPE *)mem.xmalloc(allocdim * sizeof(*data));
                }
            }
            else if (allocdim == SMALLARRAYCAP)
            {
                allocdim = dim + nentries;
                data = (TYPE *)mem.xmalloc(allocdim * sizeof(*data));
                memcpy(data, &smallarray[0], dim * sizeof(*data));
            }
            else
            {   allocdim = dim + nentries;
                data = (TYPE *)mem.xrealloc(data, allocdim * sizeof(*data));
            }
        }
    }

    void setDim(d_size_t newdim)
    {
        if (dim < newdim)
        {
            reserve(newdim - dim);
        }
        dim = newdim;
    }

    TYPE pop()
    {
        return data[--dim];
    }

    void shift(TYPE ptr)
    {
        reserve(1);
        memmove(data + 1, data, dim * sizeof(*data));
        data[0] = ptr;
        dim++;
    }

    void remove(size_t i)
    {
        if (dim - i - 1)
            memmove(data + i, data + i + 1, (dim - i - 1) * sizeof(data[0]));
        dim--;
    }

    void zero()
    {
        memset(data,0,dim * sizeof(data[0]));
    }

    void sort()
    {
        struct ArraySort
        {
            static int
    #if _WIN32
              __cdecl
    #endif
            Array_sort_compare(const void *x, const void *y)
            {
                RootObject *ox = *(RootObject **)const_cast<void *>(x);
                RootObject *oy = *(RootObject **)const_cast<void *>(y);

                return ox->compare(oy);
            }
        };

        if (dim)
        {
            qsort(data, dim, sizeof(RootObject *), &ArraySort::Array_sort_compare);
        }
    }

    TYPE *tdata()
    {
        return data;
    }

    TYPE& operator[] (d_size_t index)
    {
#ifdef DEBUG
        assert(index < dim);
#endif
        return data[index];
    }

    void insert(size_t index, TYPE v)
    {
        reserve(1);
        memmove(data + index + 1, data + index, (dim - index) * sizeof(*data));
        data[index] = v;
        dim++;
    }

    void insert(size_t index, Array *a)
    {
        if (a)
        {
            size_t d = a->dim;
            reserve(d);
            if (dim != index)
                memmove(data + index + d, data + index, (dim - index) * sizeof(*data));
            memcpy(data + index, a->data, d * sizeof(*data));
            dim += d;
        }
    }

    void append(Array *a)
    {
        insert(dim, a);
    }

    void push(TYPE a)
    {
        reserve(1);
        data[dim++] = a;
    }

    Array *copy()
    {
        Array *a = new Array();
        a->setDim(dim);
        memcpy(a->data, data, dim * sizeof(*data));
        return a;
    }
};

struct BitArray
{
    BitArray()
      : len(0)
      , ptr(NULL)
    {}

    ~BitArray()
    {
        mem.xfree(ptr);
    }

    size_t len;
    size_t *ptr;

private:
    BitArray(const BitArray&);
};

#endif
