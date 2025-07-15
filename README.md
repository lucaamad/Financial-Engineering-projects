# Financial-Engineering-projects
A collection of 8 MATLAB projects developed for my Financial Engineering course, done in collaboration with my colleagues Nicola Baldoni, Marco Barbero and Greta Belgeri. <br> 
Each project includes a detailed report and a main function that solves the assigned tasks by calling auxiliary functions contained in the project folder. When necessary, datasets are provided as an Excel/CSV file.

## Overview of the projects:

### 1. Pricing
   - Pricing of an European Call option using Black&Scholes formula, CRR tree, Monte-Carlo simulation and antithetic variables technique. <br> 
   - Pricing of an European Call option with European up&in barrier using closed formula, CRR     tree and Monte Carlo simulation. <br>
   - Pricing of a Bermudan Call option using CRR tree.

### 2. Bootstrap and interest rate sensitivities
   - Boostrap of the discount factors' curve using a single-curve model based on the interbank    market data as of February 15th, 2008 at 10:45 CET. <br>
   - Computation of DV01-parallel shift, DV01<sup>(z)</sup>-parallel shift, Basis Point Value for a plain vanilla Interest Rate swap vs Euribor and Macaulay Duration for an "Interbank Coupon Bond".

### 3. CDS and First-to-Default
   - Construction of a complete set of CDS spreads using bootstrap.
   - Computation of survival probabilities and default intensities for an obligor without taking into account the accrual term, with the accrual term and using Jarrow-Turnbull approximation.
   - Pricing of a First-to-Default.

### 4. Structured Products
   - Certificate pricing (i.e. computation of the participation coefficient) based on the hedging term sheet. <br>
   - Comparison of Digital option pricing using the Black model and the implied volatility curve. <br>
   - European Call option pricing under a normal mean-variance mixture model using Lewis formula combined with: FFT, quadrature approximation for numerical intergration, Monte Carlo simulation. <br>
   - Calibration of a normal mean-variance mixture model using S&P500 volatility surface via global calibration with constant weights.

### 5. Structured Bond pricing and hedging
   - Bootstrap of the market discount factors' curve. <br>
   - Structured bond pricing (i.e. computation of the upfront payment). <br>
   - Computation of risk measures: Delta bucket sensitivites, total Vega, Vega bucket sensitivities.
   - Hedging Delta risk with swaps. <br>
   - Hedging Vega risk with an ATM 5-years swap. <br>
   - Hedging bucketed Vega risk with a 5-years Cap and a 15-years Cap.

### 6. Structured Products II
   - Computation of the upfront payment for the hedging swap of an interest rate structured product using NIG model and Black model. <br>
   - Bermudan yearly Payer Swaption pricing using Hull-White model and a trinomial tree. <br>
   - Validation of the tree implementation using an approach based on Jamshidian formula. <br>
   - Estimation of upper and lower bounds for the price of the Bermudan yearly Payer Swaption.

### 7. Risk Management: Fixed Rate Bonds
   - Derivation of hazard rate curves for Investment-Grade and High-Yield bond issuers. <br>
   - Computation of the Z-spread for a set of fixed rate bonds. <br>
   - Derivation of the market-implied rating transition matrix.

### 8. Risk Management: Credit Portfolio Risk
   - Computation of the Present Value in a years' time of an Investment-Grade fixed rate bond according to the CreditMetrics approach. <br>
   - Computation of the 1 year 99.9% VaR for a portolio of fixed rate bonds under different issuer correlation assumptions.
