---
title: "Assignment operators in R"
author: "Amir Djalovski"
date: '26-01-2020'
output:
  html_document:
    df_print: paged
header:
  caption: ''
  image: ''
editor_options:
  chunk_output_type: console
slug: Assignment operators in R
tags: []
categories: []
---

The other day I helped a colleague of mine, who's new to R, with her script. One of the main things that jump to my eyes was the use of "=" operator instead of "<-" to assign values to a new variable. While I knew that they act differently, it is not recommended, and actually goes against Google's R style guide (a fork of (Tidyverse Style Guide)[https://style.tidyverse.org/syntax.html#assignment])  - I wasn't able to explain the full answer for "why not to use it". 

According to the help for assignments (`?assignOps`), there are three types of operators:
  1. `<-`
  2. `<<-`
  3. `=`

While the first two can assign a value also to the right (e.g. `5 -> x` and `5 ->> x`), "=" cannot (e.g. `5 = x`) and will result with error (`Error in 5 = x : invalid (do_set) left-hand side to assignment`). 

We also need to distinguish between the use of assignments inside or outside the global environment. We can use the `=` *only in top levels* (e.g., in console or in "main script") or as *subexpressions* (e.g. `data.frame(x = c(1, 2, 3)` and `list(myList = c(1, 2, 3))`). However, when we use `<-` it will be evaluated *only within its own scope*. Thus, when used inside a function, it will only operate for variables in the function. On the other hand, if `<<-` will be used, it will be evaluated (or assigned) within the global environment. Thus, a general recommendation will be to avoid `<<-` at any cost!. 

For example the function below will assign 5 only within the function's scope:
```{r}
#Create the function
inside <- function(y) {
  x <- 5
}

#Run the function
inside()

#See which variables/functions we have 
ls()

#Remove the function we created
rm(inside)
```

However, this function will assign the value 5 to the global environment:
```{r}
#Create the function
outside <- function(y) {
  x <<- 5
}

#Run the function
outside()

#See which variables/function we have 
ls()

#Remove the function and variable we created
rm(outside, x)
```

Lastly, R inferno ((a book about the weird things in R)[http://www.burns-stat.com/pages/Tutor/R_inferno.pdf]) also states that "= is not a synonym of <-" and gives the following two examples of how `=` and "<-" don't necessarily act the same.

When assigning a variable to a function:
```{r, eval=TRUE}
foo <- function(x, a) {x+ a}

foo(93, a = 5)

ls()
```

Versus (calculated `foo` and create an `a` varible):
```{r, eval=TRUE}
foo(93, a <- 5)

ls()
```
As you clearly would like to use `<-` when you set an argument of a functions. 

And when doing things like this:
```{r, eval=TRUE}
system.time(result <- foo(93, a = 5))
```

Versus (will result with error):
```{r, eval=FALSE}
system.time(result <- foo(93, a = 5))
```

When we use "=" instead of "<-", R thinks we're trying to assign the `results` argument of `system.time` - which doesn't exist!.

To sum up, if you can use either "=" or "<-", use the "<-" operator. In addition, never use the "<<-" operator. 
