%��ʼ����������  
clear;
NP=20;     %��Ⱥ����  
D=2;       %������ά��  
G=100;     %����������  
F=0.9;     %��������  
CR=0.5;    %��������  
Xs=4;      %����  
Xx=-4;     %����
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
         v(:,m)=x(:,r1)+F*(x(:,r2)-x(:,r3));  
     end 
     %�������  
     r=randi([1,NP],1,1);  
     for n=1:D  
         cr=rand(1);  
         if(cr<CR)||(n==r)  
           u(n,:)=v(n,:);  
         else  
            u(n,:)=x(n,:);  
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
  title('DEĿ�꺯������'); 
  %add by Liswer star(get the x trace data)
  figure();
  hold on;
  for ii=1:NP
      plot(x_trace(:,1,ii),x_trace(:,2,ii))
  end
  x_trace(gen,:,m)=x(:,m);
  %add by Liswer end
