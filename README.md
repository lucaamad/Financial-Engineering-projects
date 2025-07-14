# Financial-Engineering-projects
A collection of 8 MATLAB projects developed for my Financial Engineering course, done in collaboration with my colleagues Nicola Baldoni, Marco Barbero and Greta Belgeri. <br> 
Each project has a detailed report and a main function that solves the tasks by calling tha auxiliary functions contained in the project folder. When needed, the dataset is provided as an Excel/CSV file.

## Overview of the projects:

### 1. Pricing
   - Pricing of an European Call option using Black&Scholes formula, CRR tree, Monte-Carlo and        antithetic variables technique. <br> 
   - Pricing of an European Call option with European up&in barrier using closed formula, CRR     tree and Monte Carlo technique. <br>
   - Pricing of a Bermudan Call option using CRR tree.

### 2. Bootstrap and interest rate sensitivities
   - Boostrap for the discount factors' curve with a single-curve model based on the interbank    market on the 15th of February 2008 at 10:45 CET. <br>
   - Computation of DV01-parallel shift, DV01<sup>(z)</sup>-parallel shift, Basis Point Value for a plain vanilla Interest Rate swap vs Euribor and Macaulay Duration for an "Interbank Coupon Bond".

### 3. CDS and First-to-Default
   - Building a complete set of CDS spreads using bootstrap
   - Computing survival probability and intensity realted to an obligor without taking into account the accrual term, with the accrual term and using Jarrow-Turnbull approximation.
   - Pricing of a First-to-Default

### 4. Structured Products
   - Certificate pricing (i.e. computation of the participation coefficient) given the hedging termsheet. <br>
   - Comparison of the Digital option pricing with Black model and with the implied volatility curve. <br>
   - European Call option pricing according to a normal mean-variance mixture using Lewis formula combined with: FFT, Quadrature approximation for the numerical intergration, Monte Carlo. <br>
   - Calibration of a normal mean-variance mixture using S&P500 volatility surface via a global calibration with constant weights.

### 5. Structured Bond pricing and hedging
   - Bootstrap for the market discount factors's curve. <br>
   - Structured bond pricing (i.e. computation of the upfront) <br>
   - Computation of some risk measures: Delta-bucket sensitivites, total Vega, Vega-bucket sensitivities.
   - Hedging of the Delta risk with swaps. <br>
   - Hedging of the Vega risk with ATM 5 years swap. <br>
   - Hedging of the bucketed-Vega risk with a 5 years Cap and a 15 years Cap.

### 6. Structured Products 2
   - Computation of the upfront of the hedging swap of an interest rate structured product using NIG model and Black model. <br>
   - Bermudan yearly Payer Swaption pricing with Hull-White model, using trinomial tree. <br>
   - Check of the correct implementation of the tree using an approach based on Jamshidian formula. <br>
   - Estimation of upper and lower bound for the price of the Bermudan yearly Payer Swaption.

### 7. Risk Management: Fixed Rate Bonds
   - Derivation of the hazard rate curves for Investment-Grade and High-Yield bond issuers. <br>
   - Computation of the Z-spread of a set of fixed rate bonds. <br>
   - Derivation of the market-implied rating transition matrix.

### 8. Risk Management: Credit Portfolio Risk
   - Computation of the Present Value in a years' time of an Investment-Grade fixed rate bond according to the CreditMetrics approach. <br>
   - Computation of the 1 year 99.9% VaR of a portolio composed by fixed rate bonds using different values of correlation between the issuers.
