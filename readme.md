# Gilded Rose tech test

| Coverage | Tests | Tests passing | Linter |
| --- | --- | --- | --- |
| 100% | 19 | 100% |  Passing |


## Summary


This is a well known kata developed by [Terry Hughes](http://iamnotmyself.com/2011/02/13/refactor-this-the-gilded-rose-kata/). This is commonly used as a tech test to assess a candidate's ability to read, refactor and extend legacy code. A detailed description can be found below in [The Kata](#the-kata) section.'

Broadly speaking, the challenge is to take inherited spaghetti code and add a new feature, which necessitates refactoring it first.

I would like to say up front that I realise the most elegant solution is one of inheritance, however the Gilded Rose challenge places several restrictions on the developer, including that an angry Goblin will kill you if you touch the `Item` class. Since `Item` would be the superclass and would ideally contain several attributes that cascade to the subclasses, I decided against implementing this in order to remain inside the rules.

It was the first time I've used 'approval testing' which was surprisingly useful. By generating a 30-day output of the program before any code changes, then doing a diff between that and the current code output, it was very obvious when behaviour had been accidentally changed. There were a few occasions where this picked up an issue, even when tests were green. My approach was then to write an additional (failing) test before correcting the implementation, which resulted in a more robust test suite.

## Approach

#### Setting up and preparing a test suite
- Read and fully understand the business requirements
- I didn't want to embark on a refactoring with no tests, so firstly I created a test suite to cover all of the business logic requirements (`spec/gilded_rose_spec.rb`)
    - Although there are plenty of pre-built test suites out there for the Gilded Rose, I wanted the experience of doing it myself and hopefully learning something about writing tests for legacy code.
- I also wanted to ensure that the code I wrote was of a high quality, so used `Rubocop` as a linter, with appropriate exemptions to the code I wasn't permitted to change - unsurprisingly, there were a ton of linting problems with the legacy code.
- I wanted the security of being able to compare the output of the Gilded Rose running for 30 days with current code output, so made use of [LunarLogic.io's](https://blog.lunarlogic.io/2015/what-ive-learned-by-doing-the-gilded-rose-kata-4-refactoring-tips/) `texttest_fixture.rb` file, to simplify repeated updating of the store. 
    - Manually running a diff against my stored 'master' output from the beginning and the current code allowed detection of any errors that had been missed by the tests I wrote.
    
#### Tackling the refactoring
- With a test suite green and a sample output, it was time to move on to actually fixing the spaghetti
- I decided to try and unpick the conditionals in tiny pieces, so began by refactoring `Sulfuras` functionality as it had the simplest use case. I created methods outside of the main `update_quality` method containing this functionality and redirected the programme flow to this new method without otherwise affecting it.
    - This allowed me to verify the functionality of `Sulfuras` was fully implemented, without changing any of the conditional logic in the spaghetti
    - Once I was confident this worked, I was then able to start gradually moving branches of the conditional that related to `Sulfuras`, verifying that tests still passed.
- I also decided to generalise where possible, so rather than a simple check for the Sulfurus string, I decided to create a hash containing `Legendary` items, `Mature` items etc., so that future legendary items would be easily catered for
    - Although this results in a few more private helper methods, it makes the code more readable and extensible

#### Continuing the theme
Now that my approach to `Sulfuras` had been verified, with the conditional reducing in complexity and the introduction of small and easily readable methods to replace it, I followed the same approach with all the other (more complex) items:
- Create new methods to implement functionality for a product type 'in parallel'
- Redirect program flow to the new methods at the beginning of the `update_quality` method
- Verify unit tests still pass and update them if the Approval Tests find a behaviour change
- Slowly remove the (now redundant) business logic from the spaghetti conditional

#### Finishing up
- The giant conditional in `update_quality` slowly dwindled to nothing as it was refactored piece by piece
- Some final simplifications and refactorings and the end result is much clearer and extensible than the spaghetti I started with
- After writing some tests for the new conjured items, it took just a couple of minutes to actually implement Conjured items and complete the requirement; which is an indicator of a successful refactoring.

## Lessons learned

I've learnt a lot about the importance of generating an Approval Test output if possible, when dealing with legacy code. Typically when using TDD, I can take some comfort about developing them incrementally and am less likely to have missed some business logic, but having the original output caught a few edge cases that I hadn't covered with my tests which was a valuable lesson in writing better tests.

It's also rammed home to me the evils of excessive use of conditionals. I still have a `case` statement in mine of course, but that would be resolved through using a bunch of subclasses to inherit from `Item` (e.g. `LuxuryItem` etc.), but ideally I would like to have things like default increments in the parent class, and that's forbidden by the evil Goblin, so I decided not to proceed down that route as some of the benefits would have been lost. 

## The Kata

Here is the text of the kata:

*"Hi and welcome to team Gilded Rose. As you know, we are a small inn with a prime location in a prominent city run by a friendly innkeeper named Allison. We also buy and sell only the finest goods. Unfortunately, our goods are constantly degrading in quality as they approach their sell by date. We have a system in place that updates our inventory for us. It was developed by a no-nonsense type named Leeroy, who has moved on to new adventures. Your task is to add the new feature to our system so that we can begin selling a new category of items. First an introduction to our system:

All items have a SellIn value which denotes the number of days we have to sell the item. All items have a Quality value which denotes how valuable the item is. At the end of each day our system lowers both values for every item. Pretty simple, right? Well this is where it gets interesting:

- Once the sell by date has passed, Quality degrades twice as fast
- The Quality of an item is never negative
- “Aged Brie” actually increases in Quality the older it gets
- The Quality of an item is never more than 50
- “Sulfuras”, being a legendary item, never has to be sold or decreases in Quality
- “Backstage passes”, like aged brie, increases in Quality as it’s SellIn value approaches; Quality increases by 2 when there are 10 days or less and by 3 when there are 5 days or less but Quality drops to 0 after the concert

We have recently signed a supplier of conjured items. This requires an update to our system:

* “Conjured” items degrade in Quality twice as fast as normal items

Feel free to make any changes to the UpdateQuality method and add any new code as long as everything still works correctly. However, do not alter the Item class or Items property as those belong to the goblin in the corner who will insta-rage and one-shot you as he doesn’t believe in shared code ownership (you can make the UpdateQuality method and Items property static if you like, we’ll cover for you)."*

## The brief:

Choose [legacy code](https://github.com/emilybache/GildedRose-Refactoring-Kata) (translated by Emily Bache) in the language of your choice. The aim is to practice good design in the language of your choice. Refactor the code in such a way that adding the new "conjured" functionality is easy.

HINT: Test first FTW!


![Tracking pixel](https://githubanalytics.herokuapp.com/course/individual_challenges/gilded_rose.md)
