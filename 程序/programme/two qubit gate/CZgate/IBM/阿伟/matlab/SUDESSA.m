%��ʼ����������  
clear;
NP=20;     %��Ⱥ����  
D=2;       %������ά��  
G=100;     %����������  
F=0.9*ones(1,NP);     %��������  
CR=0.5*ones(1,NP);    %��������  
Xs=4;      %����  
Xx=-4;     %����

k1=0.1;
k2=0.1;
uu=0.1;
ul=0.9;
S=0.14;
  
x=zeros(D,NP);       %��ʼ��Ⱥ  
v=zeros(D,NP);       %������Ⱥ  
u=zeros(D,NP);       %ѡ����Ⱥ  
x=rand(D,NP)*(Xs-Xx)+Xx;  %����ֵ
%add by Liswer star
x_trace=zeros(G,D,NP);
%add by Liswer end
  
%������Ӧ�Ⱥ���ֵ  
for m=1:NP  
   Ob(m)=func2(x(:,m));  
end  
trace(1)=min(Ob);  
%��ֲ���  
for gen=1:G

     %�������  
     %r1,r2,r3��m������ͬ  
     for m=1:NP
         %��������Ӧ
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
         %�������  
         r=randi([1,NP],1,1);  
         for n=1:D  
             cr=rand(1); 
             if(rand(1)<S)  %ȫ�ռ�����
                 if(cr<CR(m))||(n==r)  
                     u(n,m)=v(n,m);  
                 else  
                     u(n,m)=x(n,m);  
                 end
             else  %�ӿռ�����
                 if(n==r)   
                     u(n,m)=v(n,m);  
                 else  
                     u(n,m)=x(n,m);  
                 end
             end
         end
     end 
       
     %�߽���������  
     %�߽�����  
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
     %ѡ�����  
     for m=1:NP  
         Ob1(m)=func2(u(:,m));  
     end  
       
    for m=1:NP  
        if Ob1(m)<Ob(m)      %С����ǰ��Ŀ��ֵ  
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
    X=x(:,1);          %���ű���  
    Y=min(Ob);         %����ֵ  
   disp('���ű���');  
   disp(X);  
   disp('����ֵ');  
   disp(Y);  
  %��ͼ  
  figure();  
  plot(trace);  
  %plot(X,Y,'-ro');  
  xlabel('��������');  
  ylabel('Ŀ�꺯��ֵ');  
  title('SUSSADEĿ�꺯������'); 
  %add by Liswer star(get the x trace data)
  figure();
  hold on;
  for ii=1:NP
      plot(x_trace(:,1,ii),x_trace(:,2,ii))
  end
  x_trace(gen,:,m)=x(:,m);
  %add by Liswer end
