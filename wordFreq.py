#frequency of words from moby dick(project gutenberg)
import requests
import nltk
from bs4 import BeautifulSoup
from collections import Counter

book1 = requests.get('https://www.gutenberg.org/cache/epub/60547/pg60547-images.html')
book1.encoding = 'utf-8'
html = book1.text

soup = BeautifulSoup(html, 'html.parser')
text = soup.get_text()
#print(text)

tokenizer = nltk.tokenize.RegexpTokenizer('\w+')
tokens = tokenizer.tokenize(text)
#tokens

words = [token.lower() for token in tokens]
#words
stopw = nltk.corpus.stopwords.words("english")
nstopw = [word for word in words if word not in stopw]
count = Counter(nstopw)
freq = count.most_common(10)
freq
mostCommon = freq[0]
mostCommon
