/*
 * Copyright (C) 1996-9 Brandon Long <blong@fiction.net>
 * Copyright (C) 1999 Brendan Cully <brendan@kublai.com>
 * 
 *     This program is free software; you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation; either version 2 of the License, or
 *     (at your option) any later version.
 * 
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 * 
 *     You should have received a copy of the GNU General Public License
 *     along with this program; if not, write to the Free Software
 *     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */ 

/* message.c data structures */

#ifndef MESSAGE_H
#define MESSAGE_H 1

/* -- data structures -- */
/* IMAP-specific header data, stored as HEADER->data */
typedef struct imap_header_data
{
  unsigned int uid;	/* 32-bit Message UID */
  LIST *keywords;
} IMAP_HEADER_DATA;

/* Linked list to hold header information while downloading message
 * headers */
typedef struct imap_header
{
  unsigned int read : 1;
  unsigned int old : 1;
  unsigned int deleted : 1;
  unsigned int flagged : 1;
  unsigned int replied : 1;
  unsigned int changed : 1;

  IMAP_HEADER_DATA* data;
  unsigned int number;

  time_t received;
  long content_length;
  struct imap_header *next;
} IMAP_HEADER;

/* -- macros -- */
#define HEADER_DATA(ph) ((IMAP_HEADER_DATA*) ((ph)->data))
#endif
