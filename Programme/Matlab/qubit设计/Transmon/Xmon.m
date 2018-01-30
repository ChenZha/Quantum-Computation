classdef Xmon < handle
    properties(Constant)%常量属性block
        hbar=1.054560652926899e-034;
        h = 1.054560652926899e-034*2*pi;
        e = 1.60217662e-19; 
    end
    
    properties
        Cq
        R
        A_charge
        A_flux
        A_Ic
        
    end
    properties(Dependent)
        Ec
        Ej
        E_D
        E01_D
        E12_D
        anham
        T2_charge
        T2_flux
        T2_Ic
        T2
        
    end
    %% 
    
    methods %方法block
        function obj = Xmon(Cq,R)
            obj.Cq = Cq;
            obj.R = R;
        end
        function Ec = get.Ec(obj)
            Ec = obj.e^2/2./obj.Cq/obj.h/10^9;
        end
        
        function Ej = get.Ej(obj)
            I0 = 280e-9;
            R0 = 1000;
            I = I0*R0./obj.R;
            Ej = I*obj.hbar/2/obj.e/obj.h/10^9;
        end
        %% 不同f下的能级
        
        function E = EL(obj,f,N)
            H = 4*obj.Ec.*diag([-N:N].^2)-obj.Ej./2.*cos(pi*f).*(diag(ones(1,2*N),1)+diag(ones(1,2*N),-1));
            E = eig(H);
        end
        %% 当f = 0时的能级
        
        function E_D = get.E_D(obj)
            E_D = EL(obj,0,90);
        end
        function E01_D = get.E01_D(obj)
            E01_D = obj.E_D(2)-obj.E_D(1);
        end
        function E12_D = get.E12_D(obj)
            E12_D = obj.E_D(3)-obj.E_D(2);
        end
        function anham = get.anham(obj)
            anham = obj.E12_D - obj.E01_D;
        end
        %% Noise
        function set.A_charge(obj,val)
            if val >0
                obj.A_charge = val;
            else
                error('Must Be Positive');
            end
        end        
        function set.A_flux(obj,val)
            if val >0
                obj.A_flux = val;
            else
                error('Must Be Positive');
            end
        end
        function set.A_Ic(obj,val)
            if val >0
                obj.A_Ic = val;
            else
                error('Must Be Positive');
            end
        end
        %% T2
%         function T2_charge  = T2_chargenoise(obj,A_charge)
%             A = A_charge;
%             e1 = -obj.h*obj.Ec*2^9*sqrt(2/pi)*(obj.Ej/2/obj.Ec)^(5.0/4)*exp(-sqrt(8*obj.Ej/obj.Ec));
%             T2_charge = obj.hbar/A/pi/abs(e1);
%             obj.T2_charge = T2_charge;
%             obj.A_charge = A_charge;
%         end
        
        function  T2_charge = get.T2_charge(obj)
            e1 = -obj.h*obj.Ec*10^9*2^9*sqrt(2/pi)*(obj.Ej*10^9/2/obj.Ec/10^9)^(5.0/4)*exp(-sqrt(8*obj.Ej*10^9/obj.Ec/10^9));
            T2_charge = obj.hbar/obj.A_charge/pi/abs(e1);
        end
        function  T2_flux = get.T2_flux(obj)
            T2_flux = obj.hbar/obj.A_flux^2/pi^4/sqrt(2*obj.h*obj.Ej*10^9*obj.h*obj.Ec*10^9);
        end
        function  T2_Ic = get.T2_Ic(obj)
            T2_Ic = 2*obj.hbar/obj.A_Ic/obj.h/obj.E01_D/10^9;
        end
        function T2 = get.T2(obj)
           T2 = 1/(1/obj.T2_charge+1/obj.T2_flux+1/obj.T2_Ic) ;
        end

            

        
    end
    
end