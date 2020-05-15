function HT_New = mvgarch_extrapolate(PARAMETERS, HT, X, model_params)

p = model_params.mvgarch_p;
o = model_params.mvgarch_o;
q = model_params.mvgarch_q;

if o>0
    error('Have not implemented tarch for o>0');
end

[T, N] = size(X);
T_Ht = size(HT, 3);

% PARAMETERS = [N*(1+p+o+q) tarch params; N*(N+1)/2 vech(R) params]

nTarch = 1+p+o+q;

tarch_params = NaN(nTarch, N);

for n = 1:N
    tarchOffset = nTarch*(n-1);
    tarch_params(:,n) = PARAMETERS(tarchOffset+(1:nTarch));
%     tarch_omega(n) = PARAMETERS(tarchOffset+1);
%     tarch_alpha(n,:) = PARAMETERS(tarchOffset+1+(1:p));
%     tarch_gamma(n,:) = PARAMETERS(tarchOffset+1+p+(1:o));
%     tarch_beta(n,:) = PARAMETERS(tarchOffset+1+p+o+(1:q));
end

vechlen = N*(N-1)/2;
vechR = PARAMETERS(end-vechlen+1:end);
R = corr_ivech(vechR);

% H(t) = Sigma(t) * R * Sigma(t)
% Sigma(t) = diag(Tarch(P,O,Q) vols)

%    h(i,t) = omega
%            + alpha(i,1)*r_{i,t-1}^2 + ... + alpha(i,p)*r_{i,t-p}^2+...
%            + gamma(i,1)*I(t-1)*r_{i,t-1}^2 +...+ gamma(i,o)*I(t-o)*r_{i,t-o}^2+...
%            beta(i,1)*h(i,t-1) +...+ beta(i,q)*h(i,t-q)

HT_New = zeros(N,N,T);
HT_New(:,:,1:T_Ht) = HT;

% Predict new Hts
for t = T_Ht+1:T
    for n = 1:N
        HT_New(n,n,t) = tarch_params(:,n)' * [1 ; X(t-(1:p),n).^2;  squeeze(HT_New(n,n,t-(1:q))) ];
    end
    HT_New(:,:,t) = sqrt(HT_New(:,:,t)) * R * sqrt(HT_New(:,:,t));
end