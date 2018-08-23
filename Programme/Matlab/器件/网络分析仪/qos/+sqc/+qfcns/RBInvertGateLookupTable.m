function [tblC1,tblC2] = RBInvertGateLookupTable()

I = [1,0;0,1];
X = [0,1;1,0];
Y = [0,-1i;1i,0];

X2p = expm(-1j*(pi/2)*X/2);
X2m = expm(-1j*(-pi/2)*X/2);

Y2p = expm(-1j*(pi/2)*Y/2);
Y2m = expm(-1j*(-pi/2)*Y/2);

C1 = {I, X, Y, X*Y,...
        Y2p*X2p, Y2m*X2p, Y2p*X2m, Y2m*X2m,...
        X2p*Y2p, X2m*Y2p, X2p*Y2m, X2m*Y2m,...
        X2p, X2m, Y2p, Y2m,...
        X2p*Y2p*X2m, X2p*Y2m*X2m,...
        Y2p*X, Y2m*X, X2p*Y, X2m*Y,...
        X2p*Y2p*X2p, X2m*Y2p*X2m};
    
S1 = {I, X2p*Y2p, Y2m*X2m};
S1x2p = {X2p, X2p*Y2p*X2p, Y2m};
S1y2p = {Y2p, X2p*Y, X2p*Y2m*X2m};
                            
numC1Gates = numel(C1);
numS1Gates = numel(S1);
numS1x2pGates = numel(S1x2p);
numS1y2pGates = numel(S1y2p);

tblC1 = NaN*ones(numC1Gates,numC1Gates);
for ii = 1:numC1Gates
    for jj = 1:numC1Gates
        mij = C1{ii}*C1{jj};
        for kk = 1:numC1Gates
            mi = C1{kk}*mij;
            if abs(mi(1,2)) + abs(mi(2,1)) < 0.0001 &&...
                    (abs(angle(mi(1,1)) - angle(mi(2,2))) < 0.0001 ||...
                    abs(abs(angle(mi(1,1)) - angle(mi(2,2)))- 2*pi) < 0.0001)
                break;
            end
            if kk == 24
                error('error!');
            end
        end
        tblC1(ii,jj) = kk;
    end
end


C2 = cell(1,11520);
n = 1;
for ii = 1:numC1Gates
    for jj = 1:numC1Gates
        C2{n} = kron(C1{ii},C1{jj});
        n = n+1;
    end
end
NC1C1 = n-1;

CZ = [1,0,0,0;
      0,1,0,0;
      0,0,1,0;
      0,0,0,-1];

% qubit order:
% top: q2
% bottom: q1
% kron(op(q1),op(q2))
  
for ii = 1:NC1C1
    for jj = 1:numS1Gates
        for kk = 1:numS1y2pGates
            C2{n} = kron(S1y2p{kk},S1{jj})*CZ*C2{ii};
            n = n +1;
        end
    end
end

for ii = 1:NC1C1
    for jj = 1:numS1y2pGates
        for kk = 1:numS1x2pGates
            C2{n} = kron(S1x2p{kk},S1y2p{jj})*CZ*kron(X2m,Y2p)*CZ*C2{ii};
            n = n +1;
        end
    end
end


for ii = 1:NC1C1
    C2{n} = kron(Y2p,[1,0;0,1])*CZ*kron(Y2m,Y2p)*CZ*kron(Y2p,Y2m)*CZ*C2{ii};
    n = n +1;
end
numC2Gates = n-1;

tblC2 = NaN*ones(numC2Gates,numC2Gates);
tic
for ii = 1:numC2Gates
    for jj = 1:numC2Gates
        mij = C2{ii}*C2{jj};
        tic
        for uu = 1:numC2Gates
            mi = C2{uu}*mij;
            if abs(abs(mi(1,1)) + abs(mi(2,2)) + abs(mi(3,3)) + abs(mi(4,4)) - 4) < 0.0001 &&...
                    (abs(angle(mi(1,1)) - angle(mi(2,2))) < 0.0001 ||...
                    abs(abs(angle(mi(1,1)) - angle(mi(2,2)))- 2*pi) < 0.0001) &&...
                    (abs(angle(mi(1,1)) - angle(mi(3,3))) < 0.0001 ||...
                    abs(abs(angle(mi(1,1)) - angle(mi(3,3)))- 2*pi) < 0.0001) &&...
                    (abs(angle(mi(1,1)) - angle(mi(4,4))) < 0.0001 ||...
                    abs(abs(angle(mi(1,1)) - angle(mi(4,4)))- 2*pi) < 0.0001)
                break;
            end
            if uu == numC2Gates
                error('error!');
            end
        end
        toc
        tblC2(ii,jj) = uu;
    end
    timeElpsed = toc;
    disp(sprintf('Progress: %0.2f%%. Time remaining: %0.2fhrs.',ii/numC2Gates, timeElpsed/ii*numC2Gates/3600));
end  

end