%初始化参数设置  
clear;
NP=20;     %种群数量  
D=2;       %变量的维数  
G=100;     %最大进化代数  
F=0.9*ones(1,NP);     %变异算子  
CR=0.5*ones(1,NP);    %交叉算子  
Xs=4;      %上限  
Xx=-4;     %下限

k1=0.1;
k2=0.1;
uu=0.1;
ul=0.9;
S=0.14;
  
x=zeros(D,NP);       %初始种群  
v=zeros(D,NP);       %变异种群  
u=zeros(D,NP);       %选择种群  
x=rand(D,NP)*(Xs-Xx)+Xx;  %赋初值
%add by Liswer star
x_trace=zeros(G,D,NP);
%add by Liswer end
  
%计算适应度函数值  
for m=1:NP  
   Ob(m)=func2(x(:,m));  
end  
trace(1)=min(Ob);  
%差分操作  
for gen=1:G

     %变异操作  
     %r1,r2,r3和m互不相同  
     for m=1:NP
         %参数自适应
         if(rand(1)<k1)
             F(m)=ul+rand(1)*uu;
         end
         if(rand(1)<k2)
             CR(m)=rand(1);
         end
        r1=randi([1,NP],1,1);  
        while(r1==m)  
          r1=randi([1,NP],1,1);  
        end  
         r2=randi([1,NP],1,1);  
         while(r2==m)||(r2==r1)  
          r2=randi([1,NP],1,1);  
         end  
        r3=randi([1,NP],1,1);  
         while((r3==m)||(r3==r1)||(r3==r2))  
          r3=randi([1,NP],1,1);  
         end  
         v(:,m)=x(:,r1)+F(m)*(x(:,r2)-x(:,r3));  
         %交叉操作  
         r=randi([1,NP],1,1);  
         for n=1:D  
             cr=rand(1); 
             if(rand(1)<S)  %全空间搜索
                 if(cr<CR(m))||(n==r)  
                     u(n,m)=v(n,m);  
                 else  
                     u(n,m)=x(n,m);  
                 end
             else  %子空间搜索
                 if(n==r)   
                     u(n,m)=v(n,m);  
                 else  
                     u(n,m)=x(n,m);  
                 end
             end
         end
     end 
       
     %边界条件处理  
     %边界吸收  
     for n=1:D  
       for m=1:NP  
           if u(n,m)<Xx  
               u(n,m)=Xx;  
           end  
           if u(n,m)>Xs  
               u(n,m)=Xs;  
           end  
       end  
     end  
     %选择操作  
     for m=1:NP  
         Ob1(m)=func2(u(:,m));  
     end  
       
    for m=1:NP  
        if Ob1(m)<Ob(m)      %小于先前的目标值  
            x(:,m)=u(:,m);  
        end  
    end  
    for m=1:NP  
       Ob(m)=func2(x(:,m));
        %add by Liswer star(get the x trace data)
        x_trace(gen,:,m)=x(:,m);
        %add by Liswer end
    end  
    trace(gen+1)=min(Ob); 
end  
    [SortOb,Index]=sort(Ob);  
    x=x(:,Index);  
    X=x(:,1);          %最优变量  
    Y=min(Ob);         %最优值  
   disp('最优变量');  
   disp(X);  
   disp('最优值');  
   disp(Y);  
  %绘图  
  figure();  
  plot(trace);  
  %plot(X,Y,'-ro');  
  xlabel('迭代次数');  
  ylabel('目标函数值');  
  title('SUSSADE目标函数曲线'); 
  %add by Liswer star(get the x trace data)
  figure();
  hold on;
  for ii=1:NP
      plot(x_trace(:,1,ii),x_trace(:,2,ii))
  end
  x_trace(gen,:,m)=x(:,m);
  %add by Liswer end
