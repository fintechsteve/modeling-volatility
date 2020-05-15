function cum = cumnansum(X)

nanX = isnan(X);
X(nanX) = 0;
cum = cumsum(X);
cum(nanX) = NaN;