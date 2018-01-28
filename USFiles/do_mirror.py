import sys
import time
import os

mirror_root = '/home2/mirror'
sys.path.append(os.path.join(mirror_root, 'googlescrape'))
from googlescrape import Scraper

def write_log(msg, username):
	log_path = os.path.join(mirror_root, 'mirrors.log')
	lfile = file(log_path, 'a')
	lfile.write("%s : %s at %s\n"%(msg, username, time.asctime()))
	lfile.close()

def write_message(msg):
	mpath = os.path.join(mirror_root, 'message')
	mfile = file(mpath, 'w')
	mfile.write(msg)
	mfile.close()

def clear_messages():
	mpath = os.path.join(mirror_root, 'message')
	os.remove(mpath)

def do_mirror_test(username):
	write_log("Mirror started", username)
	write_message('Crawling')
	time.sleep(20)
	write_message('Re-writing Links')
	time.sleep(20)
	write_message('Mirror Complete')
	write_log("Mirror finished", username)

def do_mirror(username):
	if os.access(os.path.join(mirror_root, 'lock'), os.F_OK):
		print 'Lock found, another process is scraping'
		return

	lock = file(os.path.join(mirror_root, 'lock'), 'w')
	lock.close()

	write_log("Mirror started", username)
	
	timestamp = time.strftime('%Y%m%d%H%M%S', time.localtime())
	#os.mkdir(os.path.join(mirror_root, timestamp))

	scraper_args = {
		'domain':'cs.usfca.edu',
		'savepath':os.path.join(mirror_root, timestamp),
		#'quiet':True,
		'verbose':True,
		'mirror':True,
	}

	s = Scraper('usfcs', **scraper_args)
	write_message('Crawling')
	try:
		s.crawl()
		s.save_urls()
		write_message('Re-writing links')
		s.rewrite_links()
	#try:
		os.remove(os.path.join(mirror_root, 'current'))
	#except OSError:
	#	pass

	#os.symlink(os.path.join(mirror_root, timestamp, 'cs.usfca.edu', 'usfcs'), '/var/www/html/usfcs')
		os.symlink(os.path.join(mirror_root, timestamp, 'cs.usfca.edu', 'usfcs'), os.path.join(mirror_root, 'current'))
		write_message('Mirror Complete')
		os.remove(os.path.join(mirror_root, 'lock'))
		write_log("Mirror finished", username)
	except Exception, e:
		write_message(str(e))



if __name__=='__main__':
	do_mirror('test')
