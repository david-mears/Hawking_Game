# Hawking Game

A game I wrote for practice/fun. Hawking chases you around space, and he's relatively good at chasing you if you are in his field of vision. The twist is you can hop away by going down a wormhole (@).

When you run the program file from the terminal, you can optionally include two arguments to specify the dimensions of the star-field. Between 5 and 20 square is probably the best way to spend your evening.

Interesting story: I originally tried to code the way Hawking checked his field of vision by using a recursive function which checked the space in front of either Hawking or a previously-checked space. However, this quickly took up far too much time. So I replaced it with an algorithm that just checks whether Hawking gets closer to the player if he moves in the direction he's currently facing, which has a similar effect and can be repurposed for making him chase you (choosing the optimal direction to go in).
