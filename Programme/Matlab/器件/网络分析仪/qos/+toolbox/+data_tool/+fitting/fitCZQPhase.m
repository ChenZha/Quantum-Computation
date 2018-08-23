function [theta1,theta2,Fcz,Fpp,chiexp] = fitCZQPhase(Pexp)
% toolbox.data_tool.fitting.fitCZQPhase

cz = [1,0,0,0;
    0,1,0,0;
    0,0,1,0;
    0,0,0,-1];
Pideal = m2p(cz);

[theta1,theta2,Fcz,Fpp,chiexp] = thetafit(Pexp,Pideal);
theta1 = -theta1;
theta2 = -theta2;

    function [theta1,theta2,Fcz,Fpp,rhoexp] = thetafit(pexp,pid)
        function y = fitFunc(pexp,pid,theta)
            pe = rotatep(pexp,theta(1),theta(2));
            D = (pe - pid).^2;
            y = sum(D(:));
        end
        
        set_fit=struct();
        set_fit.is_fit=1;
        set_fit.tolX=0;
        set_fit.tolY=1e-7;%PµÄ±ê×¼²î
        set_fit.max_feval=1e5;
        
        rhoexp=NaN(size(pexp,1),4,4);
        pexpm=NaN(size(pexp,1),size(pexp,2),size(pexp,3));
        for ii=1:size(pexp,1)
            rhoexp(ii,:,:) = sqc.qfcns.stateTomoData2Rho(squeeze(pexp(ii,:,:)),[0,0],set_fit);
            pexpm(ii,:,:)=rho2p(rhoexp(ii,:,:));
        end
        
        theta = qes.util.fminsearchbnd(@(theta)fitFunc(pexpm,pid,theta),[0,0],[-2*pi,-2*pi],[2*pi,2*pi]);
        theta1 = mod(theta(1)+pi,2*pi)-pi;
        theta2 = mod(theta(2)+pi,2*pi)-pi;
        
        prexp = rotatep(pexpm,theta1,theta2);
        rhoexp = sqc.qfcns.processTomoData2Chi(prexp);
        rhoideal = sqc.qfcns.processTomoData2Chi(pid);
        Fcz=fidelity(rhoexp,rhoideal);
        
        
        set_fit.is_fit=0;
        rhoexppp = sqc.qfcns.stateTomoData2Rho(squeeze(prexp(11,:,:)),[0,0],set_fit);
        rhoppideal = sqc.qfcns.stateTomoData2Rho(squeeze(pid(11,:,:)),[0,0],set_fit);
        Fpp=fidelity(rhoexppp,rhoppideal);
    end
    function [P] = m2p(m)
        s = cell(1,4);
        s{1} = [1;0];
        s{2} = [0;1];
        s{3} = [1;1]/sqrt(2);
        s{4} = [1;1i]/sqrt(2);
        
        rho = cell(4,4);
        for iq1 = 1:4
            for iq2 = 1:4
                rho{iq2,iq1} = kron(s{iq2}*s{iq2}',s{iq1}*s{iq1}');
            end
        end
        P = NaN(16,9,4);
        for ii = 1:16
            iq2 = fix((ii-1)/4)+1;
            iq1 = ii-(iq2-1)*4;
            rho_ = m*rho{iq2,iq1}*m';
            P(ii,:,:) = rho2p(rho_);
        end
    end

    function [P] = rho2p(rho)
        I = [1,0;0,1];
        X = [0,1;1,0];
        Y = [0, -1i; 1i,0];
        Y2m = expm(-1i*(-pi)*Y/4);
        X2p = expm(-1i*pi*X/4);
        TomoGateSet = {Y2m,X2p,I};
        u = cell(3,3);
        for u_q1 = 1:3
            for u_q2 = 1:3
                u{u_q2,u_q1} = kron(TomoGateSet{u_q2},TomoGateSet{u_q1});
            end
        end
        U = NaN(36,16);
        for Ui = 1:36 % Ui is index as {u_q2,u_q1,s_q2,s_q1}
            for Uj = 1:16 % Uj is index as {j_col_q2,j_col_q1,j_row_q2,j_row_q1}
                ui = fix((Ui-1)/4)+1;
                s = Ui-(ui-1)*4;
                u_q2 = fix((ui-1)/3)+1;
                u_q1 = ui-(u_q2-1)*3;
                s_q2 = fix((s-1)/2)+1;
                s_q1 = s-(s_q2-1)*2;
                j_col = fix((Uj-1)/4)+1;
                j_row = Uj-(j_col-1)*4;
                j_col_q2 = fix((j_col-1)/2)+1;
                j_col_q1 = j_col-(j_col_q2-1)*2;
                j_row_q2 = fix((j_row-1)/2)+1;
                j_row_q1 = j_row-(j_row_q2-1)*2;
                U(Ui,Uj) = u{u_q2,u_q1}(s,j_row)*conj(u{u_q2,u_q1}(s,j_col));
            end
        end
        P_ = U*rho(:);
        P_ = reshape(P_,4,9);
        P = P_.';
    end
    function [F] = fidelity(rho1,rho2)
        m = rho1*rho2;
        F = trace(m);
        F = sqrt(real(F));
    end
    function [pr] = rotatep(p,theta1,theta2)
        sz = size(p,1);
        pr = NaN(sz,9,4);
        Z = [1,0;0,-1];
        U = kron(expm(-1i*theta2*Z/2),expm(-1i*theta1*Z/2));
        for istate = 1:sz
            rho = sqc.qfcns.stateTomoData2Rho(squeeze(p(istate,:,:)));
            rho = U*rho*U';
            pr(istate,:,:) = rho2p(rho);
        end
        pr = real(pr);
    end
end