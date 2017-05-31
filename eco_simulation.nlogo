;better performance than lists. /mutable objects/
extensions[array]
; this reporter is used to express final price of the seller (price+random+taxes)
to-report final-price
  report price + random_term
end

;this reporter is used to express money earned by seller after the taxation!
to-report final-budget
  report revenue; same as final-price, can be used with TAXATION as coefficient, revenue = final-price * TAX
end

to-report n-of-ads
  report sum [count my-out-links] of sellers
end

to-report firstStrategyCount
  report sum [array:item lastStrategies 0] of sellers
end

to-report secondStrategyCount
  report sum [array:item lastStrategies 1] of sellers
end

to-report thirdStrategyCount
  report sum [array:item lastStrategies 2] of sellers
end

to-report fourthStrategyCount
  report sum [array:item lastStrategies 3] of sellers
end

to-report n-product-bought
  report sum [count my-in-links] of sellers
end

;herfindahl-hirschmann index
to-report hhi-index
  ifelse any? sellers with [count my-in-links > 0][
    report sum [(count my-in-links / n-product-bought) * (count my-in-links / n-product-bought)] of sellers
  ]
  [
    report 0
  ]
end

to-report avg-price_in_round
  let sumOfSoldProducts 0
  let avg_price 0
  if any? sellers with [count my-in-links > 0]
  [
    set sumOfSoldProducts sum [revenue * count my-in-links] of sellers
    set avg_price sumOfSoldProducts / n-product-bought
    report avg_price
  ]
    report 0
end

to-report n-sellers
  report count sellers
end

;define our agents
breed [sellers seller]
breed [buyers buyer]

globals [
  n_products_sold
  avg_price_of_product
  n_of_sellers
  n_of_ads
  avg_price_in_round
  ticks_since_seller_death
]


;variables of sellers
sellers-own [
  revenue ;total price determined price + random = set revenue price + random_term.
  price ;is determined by Seller
  random_number ;number used to pick strategy.
  random_term ;is uniformly distributed random term
  income ;how effective are strategies / revenue of each strategy.
  vector ;how likeable is each strategy to occur
  budget ;how much money has each agent
  strategy ;which strategy agent uses (0,1,2,3)
  sell_count ;how many good seller sold in the current tick.
  count_vector ;how many times was each strategy played.
  averageIncome
  exponentialAverage
  proportionsBuyersSellers
  earnings
  lastStrategies
]

;this function choose strategies according to random-number.
to choose_Strategy
  if(random_number < (array:item vector 0))[
      first_Strategy
    ]

    if(random_number < (array:item vector 0 + array:item vector 1) and random_number > array:item vector 0)[
      second_Strategy
    ]

    if(random_number < (array:item vector 0 + array:item vector 1 + array:item vector 2) and random_number > (array:item vector 0 + array:item vector 1))[
      third_Strategy
    ]
    if(random_number < (array:item vector 0 + array:item vector 1 + array:item vector 2 + array:item vector 3) and random_number > (array:item vector 0 + array:item vector 1 + array:item vector 2))[
      fourth_Strategy
    ]
end

;first strategy.
to first_Strategy
   ask sellers with [random_number < (array:item vector 1)][
     set price 1
     set color red
     set strategy 0
     set revenue final-price
   ]
end

;second one
to second_Strategy
   ask sellers with [(random_number < (array:item vector 0 + array:item vector 1) and random_number > array:item vector 0)][
     set price 1
     set strategy 1
     set color yellow
     set revenue final-price
   ]
end

;third one
to third_Strategy
   ask sellers with [random_number < (array:item vector 0 + array:item vector 1 + array:item vector 2) and random_number > (array:item vector 0 + array:item vector 1)][
     set price 0
     set color brown
     set revenue final-price
     set strategy 2
   ]
end

;fourth one
to fourth_Strategy
   ask sellers with [random_number < (array:item vector 0 + array:item vector 1 + array:item vector 2 + array:item vector 3) and random_number > (array:item vector 0 + array:item vector 1 + array:item vector 2)][
     set price 0
     set strategy 3
     set color cyan
     set revenue final-price
   ]
end

;
to check ;this function checks the income vector and when there is a negative number, replace it with 0.
  ask sellers[
    if array:item income 0 < 0[
      array:set income 0 0
    ]
    if array:item income 1 < 0[
       array:set income 1 0
    ]
    if array:item income 2 < 0[
       array:set income 2 0
    ]
    if array:item income 3 < 0[
       array:set income 3 0
    ]
  ]
end

;this function recapitulate last round, changes probability array, generate random numbers for choosing strategy, choose strategy for agents, etc.
to update
  clear-links
  ask sellers[
     set lastStrategies array:from-list [0 0 0 0]
   ]
  ask sellers[
   set sell_count 0
   set random_term random-float 1
   set random_number random-float 1
   ;this function CHECKS which strategy the program should use.
   array:set averageIncome 0 (array:item income 0 / array:item count_vector 0)
   array:set averageIncome 1 (array:item income 1 / array:item count_vector 1)
   array:set averageIncome 2 (array:item income 2 / array:item count_vector 2)
   array:set averageIncome 3 (array:item income 3 / array:item count_vector 3)
  ]
end

to kill
  ask sellers with [budget < 0][
    die
  ]
end

to setup
  ca ;clearall
  set ticks_since_seller_death 0
  create-sellers num-sellers[
    set color green
    set shape "person"
    set income array:from-list [1000 1000 1000 1000]
    set budget 10000
    set vector array:from-list [0 0 0 0]
    set count_vector array:from-list [1 1 1 1]
    set averageIncome array:from-list [0 0 0 0]
    set lastStrategies array:from-list [0 0 0 0]
    set proportionsBuyersSellers num-buyers / num-sellers
  ]

  create-buyers num-buyers[
    set color blue
    set shape "sheep"
  ]

  ask buyers[
    setxy -10 random-pycor
  ]

  ask sellers[
    set exponentialAverage array:from-list [0 0 0 0]
    set price random-float 1 ;set the price for their products/ ENTRY PRICE? /
    array:set exponentialAverage 0 proportionsBuyersSellers
    array:set exponentialAverage 1 proportionsBuyersSellers
    array:set exponentialAverage 2 proportionsBuyersSellers
    array:set exponentialAverage 3 proportionsBuyersSellers
    setxy 10 random-pycor
  ]
  reset-ticks
end


to go


  update ;function update
  ask sellers[
    choose_strategy
  ]
  ask sellers with [strategy = 0][
    array:set count_vector 0 (array:item count_vector 0 + 1)
    ifelse ((alfa * array:item averageIncome 0) + ((1 - alfa) * earnings)) > epsilon[
       array:set exponentialAverage 0 ((alfa * array:item averageIncome 0) + (1 - alfa) * earnings)
     ]
     [
       array:set exponentialAverage 0 epsilon
     ]
  ]
  ask sellers with [strategy = 1][
    array:set count_vector 1 (array:item count_vector 1 + 1)
    ifelse ((alfa * array:item averageIncome 1) + ((1 - alfa) * earnings)) > epsilon[
       array:set exponentialAverage 1 ((alfa * array:item averageIncome 1) + (1 - alfa) * earnings)
     ]
     [
       array:set exponentialAverage 1 epsilon
     ]
  ]
  ask sellers with [strategy = 2][
    array:set count_vector 2 (array:item count_vector 2 + 1)
    ifelse ((alfa * array:item averageIncome 2) + ((1 - alfa) * earnings)) > epsilon[
       array:set exponentialAverage 2 ((alfa * array:item averageIncome 2) + (1 - alfa) * earnings)
     ]
     [
       array:set exponentialAverage 2 epsilon
     ]
  ]
  ask sellers with [strategy = 3][
    array:set count_vector 3 (array:item count_vector 3 + 1)
    ifelse ((alfa * array:item averageIncome 3) + ((1 - alfa) * earnings)) > epsilon[
       array:set exponentialAverage 3 ((alfa * array:item averageIncome 3) + (1 - alfa) * earnings)
     ]
     [
       array:set exponentialAverage 3 epsilon
     ]
  ]
  ask sellers[
   array:set vector 0 (array:item exponentialAverage 0 / (array:item exponentialAverage 0 + array:item exponentialAverage 1 + array:item exponentialAverage 2 + array:item exponentialAverage 3))
   array:set vector 1 (array:item exponentialAverage 1 / (array:item exponentialAverage 0 + array:item exponentialAverage 1 + array:item exponentialAverage 2 + array:item exponentialAverage 3))
   array:set vector 2 (array:item exponentialAverage 2 / (array:item exponentialAverage 0 + array:item exponentialAverage 1 + array:item exponentialAverage 2 + array:item exponentialAverage 3))
   array:set vector 3 (array:item exponentialAverage 3 / (array:item exponentialAverage 0 + array:item exponentialAverage 1 + array:item exponentialAverage 2 + array:item exponentialAverage 3))
  ]
  ask sellers with [strategy = 0][ ;those with money for advertising
       ifelse (budget / price-of-ad) < num-buyers[ ; condition checks whether there is enough buyers ( for ads)
         create-links-to n-of (budget / price-of-ad) buyers
       ]
       [
         create-links-to n-of num-buyers buyers
       ]

    set budget budget - (count my-out-links * price-of-ad)
    array:set income 0 (array:item income 0 - (count my-out-links * price-of-ad))
  ]
  ask sellers with [strategy = 3][ ;those with money for advertising
       ifelse ( budget) / price-of-ad < num-buyers[ ; condition checks whether there is enough buyers ( for ads)
         create-links-to n-of (( budget) / price-of-ad) buyers
       ]
       [
         create-links-to n-of num-buyers buyers
       ]

    set budget budget - (count my-out-links * price-of-ad)
    array:set income 3 (array:item income 3 - (count my-out-links * price-of-ad))
  ]

  ask buyers with [count my-in-links > 0][
    let cheapest-price [revenue] of min-one-of in-link-neighbors [revenue]
    let cheapest-seller min-one-of in-link-neighbors [revenue]

    if  cheapest-price < (1 * treshold) and (count my-in-links) = num-sellers[    ; checking whether the random sellers has lower price than treshold T
      ask cheapest-seller[
        set budget (budget + final-budget)
        set sell_count sell_count + 1
        array:set income strategy (array:item income strategy + final-budget)
        create-link-from myself [set color green]

      ]
    ]
    if cheapest-price < (1 * treshold) and ((count my-in-links) != num-sellers)[
        ask cheapest-seller[
          set budget (budget + final-budget)
          set sell_count sell_count + 1
          array:set income strategy (array:item income strategy + final-budget)
          create-link-from myself [set color green]
        ]
    ]
   if cheapest-price > (1 * treshold) and ((count my-in-links) != num-sellers)[ ;there MUST be one seller without links to ask one (condition below this line)
     if any? sellers with [out-link-neighbor? myself = false][
       ask one-of sellers with [out-link-neighbor? myself = false][
         ifelse [revenue] of self > (1 * treshold)[
         ]
         [
           set budget (budget + final-budget)
           set sell_count sell_count + 1
           array:set income strategy (array:item income strategy + final-budget)
           create-link-from myself [set color green]

         ]
       ]
     ]
   ]
  ]

   ask buyers with [count my-in-links = 0][
     if any? sellers[ ;there MUST be one seller without links to ask one (condition below this line)
       ask one-of sellers[
         ifelse [revenue] of self > (1 * treshold)[
         ]
         [
           set budget (budget + final-budget)
           set sell_count sell_count + 1
           array:set income strategy (array:item income strategy + final-budget)
           create-link-from myself [set color green]
         ]
       ]
     ]
   ]
   ;at the end of the round cut budget of sellers by fixedtax <0,10>
   ask sellers[
     set budget budget - fixedtax
   ]

  ask sellers with [strategy = 0][
    array:set income 0 (array:item income 0 - fixedtax)
  ]
  ask sellers with [strategy = 1][
    array:set income 1 (array:item income 1 - fixedtax)
  ]
  ask sellers with [strategy = 2][
    array:set income 2 (array:item income 2 - fixedtax)
  ]
  ask sellers with [strategy = 3][
    array:set income 3 (array:item income 3 - fixedtax)
  ]
    ask sellers[
  set earnings ((count my-in-links * final-budget) - (count my-out-links * price-of-ad) - fixedtax)
  ]


   check ;calls function CHECK, which checks INCOME vector and replace negative number with zero.
   kill ;calls function KILL, which KILLS all sellers with < 0

   ask sellers with [strategy = 0][
     array:set lastStrategies 0 1
   ]
   ask sellers with [strategy = 1][
     array:set lastStrategies 1 1
   ]
   ask sellers with [strategy = 2][
     array:set lastStrategies 2 1
   ]
   ask sellers with [strategy = 3][
     array:set lastStrategies 3 1
   ]
   ; deleting data when 1 of the seller dies.
   tick
   ifelse (n_of_sellers > count sellers) [ ; check whether one seller died.
     set ticks_since_seller_death 0

  ]
  [
    set ticks_since_seller_death ticks_since_seller_death + 1 ; increment ticks since the death of 1 seller by one.
  ]
  ; tu to ohradime, nech sa vysledky zaznamenavaju z poslednych 100 runov
  set n_products_sold n-product-bought
  ;set avg_price_in_round avg_price_in_round + avg-price_in_round
  set n_of_ads n-of-ads
  set n_of_sellers count sellers


end
