//
// Simple Poisson regression model for pest_data
//

// Data block (curly braces delineate a block)
// declare the names and sizes of variables that will be used
// white spaces are ignored and ; is line ender and is required.
data { 
  int<lower=0> N; // numer of observations
  /*
  this is a multi-line comment
  */
  int<lower=0> complaints[N];
  // int<lower=0, upper=1> logical_var[N] is possible
  vector<lower=0>[N] traps; // vector is real-valued numbers
  // alternative
  // real<lower=0> traps[N];
  // real x; // this is a single real number
  /*
  In stan, arrays are "containers" that can store whatever.  
  Putting the [number of observations] after the "vector" says that traps
  is a vector, not an array. so 
  vector[N] x[K];
  then x is an array of K length-N vectors and
  matrix[N,N] m[K];
  and m is an array of K NxN matrices
  each of the [] can have multiple dimensions as needed.
  Side note: Stan uses matrix/vector multiplication, etc. rather than elementwise, by default
  Stan can do linear algebra with matrices and vectors and NOT with arrays.
  */
}

// transformed data block goes here (if there is one)

// now, for the unknown quantities we want to estimate:
parameters {
  real alpha; // can add constraints here if there are any
  real beta;
}

// transformed parameters block goes here (if there is one)

/*
transformed parameters {
  //could define eta here 
  vector[N] eta = alpha + beta *  traps;
  //but then all the values of eta will be returned with output
}

*/

//in this model block, things can be computed (temporary variables like eta) but then they will not be stored in output
model {
  vector[N] eta;
  eta = alpha + beta * traps; // loops are also possible
  // alternative one-line version:
  // vector[N] eta = alpha + beta * traps;
  complaints ~ poisson_log(eta);
  /*when calling distribution functions like the line above do NOT do a loop - vectorization is important
  because there's lots of derivative/gradient calculations
  if it's just doing calculations for each element the loop is just as fast
  */
  // alternative (not as preferred):
  // complaints ~ poisson(exp(eta));
  // alternative to NOT use:
  // for( n in 1:N ) { complaints ~ poisson_log(eta[n])}
  // there's also a function binomial_logit()
  
  //priors. the tilde means that alpha has PDF ...
  alpha ~ normal( log(4), 1);
  beta ~ normal(-0.25, 1);
}

generated quantities {
  // we will use this for prior predictive checks
  // here, in-sample predictions (predict for the observed dataset - trying to "replicate" our data)
  // could also do out-of-sample
  int y_rep[N];
  for (n in 1:N){
    y_rep[n] = poisson_log_rng(alpha + beta * traps[n]);
  } 
}
