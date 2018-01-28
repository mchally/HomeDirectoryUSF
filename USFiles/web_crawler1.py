import requests
import os, webbrowser
#-----------------------------------------------------------------
def depth_1st_srch(page_db, current_link, root_url):
   current_page = requests.get(current_link)
   word_list = []
   link_list = []
   build_lists(current_page, word_list, link_list, root_url)
   page_db[current_link] = word_list
   for link in link_list:
      if not link in page_db:
         depth_1st_srch(page_db, link, root_url)
   return page_db

def build_lists(current_page, word_list, link_list, root_url):
   lines = current_page.content.split('\n')
   for line in lines:
      if line[0] != '<':
         word_list.append(str(line))
      elif line[0:8] == '<a href=':
         link = line[9:len(line)-2]
         new_link = str(root_url + '/' + link)
         link_list.append(new_link)

def reverse_dic(page_db):
   for key in page_db:
      val = page_db[key]
      for i in range(len(val)):
         if not val[i] in rev_db:
            rev_db[val[i]] = [key]
         else:
            rev_db[val[i]].append(key)
   return rev_db
#----------------------------------------------------------------
def menu():
   """Print a menu of options"""
   print "You can:"
   print "   Search the database for a word (s)"
   print "   Open a URL in a browser (o)"
   print "   Print the dictionary with keys that are URLs (u)"
   print "   Print the dictionary with keys that are words on web pages (w)"
   print "   Print this menu (m)"
   print "   Quit (q)"
#----------------------------------------------------------------
def word_search(page_db):
   """Search for a word in the database"""
   word = raw_input("what's the word you want to search for?\n   ")
   link_list = []
   for link in page_db:
      word_list = page_db[link]
      if word in word_list:
         link_list.append(link)
   print
   for i in xrange(len(link_list)):
      print link_list[i]
#------------------------------------------------------------------
def open_browser():
   url = raw_input("enter a url?\n   ")
   os.system("firefox " + url + "&")

#------------------------------------------------------------------
def print_by_words(rev_db):
   for i in rev_db:
      print
      print i
      for j in rev_db[i]:
         print j
#------------------------------------------------------------------
def print_by_keys(page_db):
   for i in page_db:
      print
      print i
      for j in page_db[i]:
         print j
#------------------------------------------------------------------
def update_query():
   menu()
   cmd = raw_input("Enter a command (s, o, u, w, m, q)\n   ")
   while cmd != "q" and cmd != "Q":
      if cmd == "s" or cmd == "S":
         word_search(page_db)
      elif cmd == "o" or cmd == "O":
         open_browser()
      elif cmd == "u" or cmd == "U":
         print_by_keys(page_db)
      elif cmd == "w" or cmd == "W":
         print_by_words(rev_db)
      elif cmd == "m" or cmd == "M":
         menu()
      else:
         print cmd, "isn't a valid command. Please try again"
         menu()
      cmd = raw_input("Enter a command (s, o, u, w, m, q)\n   ")

#-----------------------------------------------------------------
#main program
page_db = dict()
rev_db = dict()

root_url = raw_input('What is the root URL of the website?\n')
file_name = raw_input('What is the name of the file?\n')
first_link = root_url + '/' + file_name

depth_1st_srch(page_db, first_link, root_url)
reverse_dic(page_db)
update_query()


