
# A very very rudimentary and simplistic python program to extract specific json key 
# and print the value out.
import sys, json

js=sys.argv[1]
k=sys.argv[2] 

print (json.loads(js)[k])


