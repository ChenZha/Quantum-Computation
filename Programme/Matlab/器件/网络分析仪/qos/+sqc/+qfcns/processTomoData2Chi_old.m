function chi = processTomoData2Chi(data)
 
    numQs = round(log2(size(data,1))/2);
    switch numQs
        case 1
            rho = cell(1,4);
            for ii = 1:size(data,1)
                rho{ii} = sqc.qfcns.stateTomoData2Rho(squeeze(data(ii,:,:)));
            end

        %     rho{1} = [0,0;0,1];
        %     rho{2} = [1,0;0,0];
        %     rho{3} = [0.5,0.5;0.5,0.5];
        %     rho{4} = [0.5,-0.5i;0.5i,0.5];

            rho_ = [rho{1},...
                rho{3}+1j*rho{4}-(1+1j)*(rho{1}+rho{2})/2;...
                rho{3}-1j*rho{4}-(1-1j)*(rho{1}+rho{2})/2,...
                rho{2}];
        %     lambda = [1 0 0 1; 0 1 1 0; 0 1 -1 0; 1 0 0 -1];
             lambda = [1 0 0 1; 0 1 1 0; 0 1j -1j 0; 1 0 0 -1];
             chi = conj(lambda)*rho_*lambda.'/4;
        case 2
            rho = cell(4,4);
            for sq1 = 1:4
                for sq2 = 1:4
                    rho{sq2,sq1} = sqc.qfcns.stateTomoData2Rho(squeeze(data((sq2-1)*4+sq1,:,:)));
                end
            end
            rho_ = cell(4,4);
            for ii = 1:4
                rho_{ii,1} = rho{ii,1};
                rho_{ii,2} = rho{ii,3}+1j*rho{ii,4}-(1+1i)*(rho{ii,1}+rho{ii,2})/2;
                rho_{ii,3} = rho{ii,3}-1j*rho{ii,4}-(1-1i)*(rho{ii,1}+rho{ii,2})/2;
                rho_{ii,4} = rho{ii,2};
            end
            rho = rho_;
            for jj = 1:4
                rho_{1,jj} = rho{1,jj};
                rho_{2,jj} = rho{3,jj}+1j*rho{4,jj}-(1+1i)*(rho{1,jj}+rho{2,jj})/2;
                rho_{3,jj} = rho{3,jj}-1j*rho{4,jj}-(1-1i)*(rho{1,jj}+rho{2,jj})/2;
                rho_{4,jj} = rho{2,jj};
            end
            r = [rho_{1,1},rho_{1,2},rho_{2,1},rho_{2,2};
                rho_{1,3},rho_{1,4},rho_{2,3},rho_{2,4};
                rho_{3,1},rho_{3,2},rho_{4,1},rho_{4,2};
                rho_{3,3},rho_{3,4},rho_{4,3},rho_{4,4};];
            r1 = [1 0; 0 0];
            r2 = [0 1; 0 0];
            r3 = [0 0; 1 0];
            r4 = [0 0; 0 1];
            r11 = kron(r1,r1);
            r23 = kron(r2,r3);
            r32 = kron(r3,r2);
            r44 = kron(r4,r4);
            I = [1 0;0 1];
            P = kron(I,kron(r11+r23+r32+r44,I));
            r_ = (P.')*r*P;
            lambda = [1 0 0 1; 0 1 1 0; 0 1 -1 0; 1 0 0 -1]/2;
            lambda2 = kron(lambda,lambda);
            chi_ = lambda2*r_*lambda2; % chi_ is the process matrix for operator set E = {I,X,-iY,Z};
            U = [1 0 0 0;
                0 1 0 0;
                0 0 1i 0;
                0 0 0 1];
            chi = kron(U,U)*chi_*kron(U,U)';
        otherwise
            error('TODO');
    end
end