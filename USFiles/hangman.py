import random

def randomPhrase(phrases):
	i = random.randrange(0,len(phrases))
	return phrases[i]

# take a phrase and replace all letters with underscores, leaving spaces alone
def generateHiddenPhrase(phrase):
	hiddenPhrase = list(phrase)
	for i in range(0,len(hiddenPhrase)):
		if hiddenPhrase[i]!= ' ':
			hiddenPhrase[i]='_'
	return hiddenPhrase

# check for a letter in phrase. If match, place that letter in hiddenPhrase
def processGuess(phrase, hiddenPhrase,letter):
	match = False
	for i in range(0,len(hiddenPhrase)):
		if phrase[i]==letter:
			hiddenPhrase[i]=letter
			match=True
	return match

def gameWon(phrase, hiddenPhrase):
	s = ''.join(hiddenPhrase)
	if phrase==s:
		return True
	else:
		return False
	
# show a list as a string, below does this with spaces between items
def listAsString(list):
	return ' '.join(list)	
		
# main
phrases = ["pink elephant","sports illustrated","rolling stones"]
phrase= randomPhrase(phrases)
hiddenPhrase = generateHiddenPhrase(phrase)
misses=0
MAXMISSES=10
while ((misses<MAXMISSES) and ( not gameWon(phrase,hiddenPhrase))):
	print listAsString(hiddenPhrase)
	letter = raw_input('please enter a guess: ')
	if not processGuess(phrase, hiddenPhrase,letter):
		misses=misses+1
		print "sorry, letter not in phrase, you now have ",misses," misses."
if gameWon(phrase,hiddenPhrase):
	print "NICE JOB!"
else:
	print "Game over, please try again!"

