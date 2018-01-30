% author:zhaoyouwei
% data:2017/3/21
% version:1.3
% filename:DACMVC.m
% describe:DAC测试类

% 依赖文件：GUI Layout Toolbox
classdef DACMVC < handle
% MODEL & VIEW & CONTROLLER
% without instrument
    properties
        handles;
        logdastr;
    end
    properties
        n9030b;
        numoffreq;
        setDACfreq;
        setDACfreq_instrument;
        getdata;
        testfreqpreset=1;
        testfreqliststr='[3.33,5.63,10.37,15.83,20.745,32.15,47.55,56.43,72.45,83.14,104.69,125.46,134.16,148.83,168.13,195.23,249.99,275.36,300.53,350.34,387.56,412.33,489.55,560.364,671.46,740.314]*1e6';
        %[linspace(3.33,151.45,20) linspace(155.34,890.35,20)]*1e6
    end
    properties
        dpo70404c;
    end
    
    methods
        function  obj = DACMVC(setDACfreq)
            % setDACfreq:一个函数句柄
            % pausetime=setDACfreq(freq,ip);
            % 把DAC的输出频率设为freq单音，-9dBFS，并返回一个等待时间
            if ~nargin
                setDACfreq=@(x,ip) 0;
            end
            obj.setDACfreq_instrument=setDACfreq;
            %处理各仪器的simulate
            obj.setDACfreq=@(x,ip) 0;
            temp_aaa=zeros(100001,1);
            temp_aaa(ceil(100001/2*rand()))=82;
            obj.getdata=@() temp_aaa+rand(100001,1);
            GUI(obj)
        end
 
        function init(obj,o,e) %#ok<INUSD>
            disp('init spc');
%             obj.handles.initbutton.Visible='off';
%             obj.handles.textbox11.Visible='off';
%             obj.handles.ipinputbox.Visible='off';
%             %ip='TCPIP0::10.0.0.101::inst0::INSTR';
%             %obj.n9030b = visa('agilent',ip);
%             obj.n9030b =tcpip(obj.handles.ipinputbox.String, 5025);
%             obj.n9030b.InputBufferSize = 8388608;%8388608  (1e5+1)*64=6400064
%             obj.n9030b.Timeout = 30;
%             obj.n9030b.ByteOrder = 'bigEndian';%'littleEndian';
%             fopen(obj.n9030b);
%             fprintf(obj.n9030b,':POW:RF:ATT 0dB');%set the attenuator to 0 dB
%             fprintf(obj.n9030b,':INIT:CONT ON');%Puts analyzer in Continuous measurement operation
%             obj.getdata=@()obj.GetSpectrumAnalysis(0, 1e9, 10000, 100001);
%             %
%             obj.setDACfreq=obj.setDACfreq_instrument;
%             obj.handles.starttestbutton.String='start test'; 
        end
        
        function starttest(obj,o,e) %#ok<INUSD>
            obj.handles.starttestbutton.Visible='off';
            time=datestr(now,'yyyymmdd_HHMMSS');
            logdastr=['obj.handles.' obj.handles.loginputbox.String]; %#ok<PROPLC>
            logdastr2=[obj.handles.loginputbox.String];
            obj.logdastr=logdastr; %#ok<PROPLC>
            if obj.testfreqpreset==0
                testfreqlist=eval(obj.handles.freqlistinputbox.String);
                obj.numoffreq=numel(testfreqlist);
            end
            if obj.testfreqpreset==1
                testfreqlist=eval(obj.testfreqliststr);
                obj.numoffreq=numel(testfreqlist);
            end
            [resultSFDR,resultSNR]=SFDRandSNR(obj,obj.setDACfreq,obj.getdata,testfreqlist);
            plot(testfreqlist,resultSFDR,'parent',obj.handles.ha1);
            plot(testfreqlist,resultSNR,'parent',obj.handles.ha2);
            xlabel(obj.handles.ha1,'fout Hz');
            ylabel(obj.handles.ha1,'SFDR dBc');    
            ylim(obj.handles.ha1,[-100 0]);
            title(obj.handles.ha1,'SFDR');
            xlabel(obj.handles.ha2,'fout Hz');
            ylabel(obj.handles.ha2,'SNR dBc');
            title(obj.handles.ha2,'SNR');
            %set(obj.handles.ha1,'ylim',[-100 0])
            
            eval([logdastr2 '=' logdastr ';' ]) %#ok<PROPLC>
            eval([logdastr2 '.SFDR=resultSFDR;'])
            eval([logdastr2 '.SNR=resultSNR;'])
            eval([logdastr2 '.testfreqlist=testfreqlist;'])
            eval([logdastr2 '.log=''' time ' (0, 1e9, 100000, 100001)~[startfreq, stopfreq, bandwidth, numpts]  avgnum = 100 '  ''';'])           
            %eval([ 'save(''' ['log\' logdastr2 '.mat'] ''',''' logdastr2 ''');'] )
            obj.handles.starttestbutton.Visible='on';
        end
        
        function [resultSFDR,resultSNR] = SFDRandSNR(obj,setDACfreq,getdata,testfreqlist)
            % setDACfreq:一个函数句柄
            % pausetime=setDACfreq(freq,ip);
            % 把DAC的输出频率设为freq单音，-9dBFS，并返回一个等待时间
            % getdata=@() GetSpectrumAnalysis(obj,0, 1e9, 10000, 100001);%约1s
                    %此处假设频谱仪输出纵坐标是能量以dBc为基准的对数
            resultSFDR=zeros(1,obj.numoffreq);
            resultSNR=zeros(1,obj.numoffreq);
            %freqs=linspace(0,1e9,100001);
            fullwidth=ones(1,41);%~0.4MHz  bw=0.1MHz时，(全高全宽?)0.4MHz
            %logical(conv2(double(a),fullwidth,'same'));
            eval([obj.logdastr '.SpectrumAnalysis=cell(1,' num2str(obj.numoffreq) ');'])
            tic
            for index1 = 1:obj.numoffreq
                outfreq=testfreqlist(index1);
                pause(setDACfreq(outfreq,obj.handles.dacipinputbox.String));
                result=getdata();
                [maxdBc,maxfreqindex]=max(result(41:end));%得到当前信号频率
                maxfreqindex=maxfreqindex+40;
                %maxfreq=(maxfreqindex-1)*1e4;
                sixtimes=bsxfun(@plus,[-6,-5,-4,-3,-2,-1,0,1,2,3,4,6]*(maxfreqindex-1),[-6,-5,-4,-3,-2,-1,0,1,2,3,4,6]'*200000+1);
                sixtimes(sixtimes>100001)=1;
                sixtimes(sixtimes<1)=1;
                sixtimes=reshape(sixtimes,1,[]);%六次谐波以内以及直流成分
                timesfreqindexbool=logical(zeros(size(result))); %#ok<LOGL>
                timesfreqindexbool(sixtimes)=1;
                timesfreqindexbool(maxfreqindex)=0;
                timesfreqindexbool(1)=0;
                timesfreqindexbool=logical(conv2(double(timesfreqindexbool),fullwidth,'same'));%处理展宽+频率偏移
                resultSFDR(index1)=-(maxdBc-max(result(timesfreqindexbool)));%信号减去除信号外的最大值
                    
                timesfreqindexbool(timesfreqindexbool)=0;
                timesfreqindexbool(sixtimes)=1;%六次谐波以内以及直流成分
                timesfreqindexbool=logical(conv2(double(timesfreqindexbool),fullwidth,'same'));%处理展宽+频率偏移
                SNR_temp=sum(10.^(result(timesfreqindexbool)./10))/sum(10.^(result(~timesfreqindexbool)./10));
                            %(一~六倍频以及直流成分总能量/其他总能量）
                resultSNR(index1)=10*log10(SNR_temp);
                
                eval([obj.logdastr '.SpectrumAnalysis{' num2str(index1) '}=result;'])
                disp(index1);toc;
            end
        end
        

        %%
        
        function initosc(obj,o,e) %#ok<INUSD>
            disp('init osc');
        end
        
        function starttestosc(obj,o,e) %#ok<INUSD>
            obj.handles.starttestbuttonosc.Visible='off';
            disp('starttestosc');
            obj.handles.starttestbuttonosc.Visible='on';
        end
        
        %%
        function GUI(obj)   
            %layout
            %addpath('layout')
            obj.handles.hfig=figure('pos',[50,50,1000,700], 'Name', 'DAC-Quality-Testing','MenuBar', 'none','Toolbar', 'none','NumberTitle', 'off' );
            mainlayout=uix.Grid('parent',obj.handles.hfig);
            axeslayout=uicontainer('parent',mainlayout);
            meaulayout=uix.TabPanel('parent',mainlayout,'TabWidth',65);
            obj.handles.meaulayout=meaulayout;
            mainlayout.Heights=[-5 -2];
            initlayout=uix.Grid('parent',meaulayout,'padding',10);
            freqlayout=uix.Grid('parent',meaulayout,'padding',10);
            osclayout=uix.Grid('parent',meaulayout,'padding',10);
            meaulayout.TabTitles={'spc','freqsettings','osc'};
            
            %initlayout
                %botton
            obj.handles.initbutton=uicontrol('parent',initlayout,'string','init spc');
            obj.handles.starttestbutton=uicontrol('parent',initlayout,'string','simulate');
            uix.Empty( 'Parent', initlayout );
                %log DA_id  & ip
            obj.handles.textbox10=uicontrol('parent',initlayout,'style','text','string','DAC id');
            obj.handles.textbox11=uicontrol('parent',initlayout,'style','text','string','N9030B ip');
            obj.handles.textbox12=uicontrol('parent',initlayout,'style','text','string','DAC ip');
            obj.handles.loginputbox=uicontrol('parent',initlayout,'style','edit',...
                'string','DA_id','tag','inputbox');
            obj.handles.ipinputbox=uicontrol('parent',initlayout,'style','edit',...
                'string','10.0.0.101','tag','inputbox');
            obj.handles.dacipinputbox=uicontrol('parent',initlayout,'style','edit',...
                'string','10.0.1.101','tag','inputbox');
            initlayout.Heights=[-1 -1 -1];
            initlayout.Widths=[-1 100 -3];
            set(obj.handles.initbutton,'callback',@(o,e)obj.init(o,e));
            set(obj.handles.starttestbutton,'callback',@(o,e)obj.starttest(o,e));
            
            %freqlayout
            uix.Empty( 'Parent', freqlayout );
            obj.handles.nonpresetbutton=uicontrol('parent',freqlayout,'string','Non preset');
            obj.handles.textbox7=uicontrol('parent',freqlayout,'style','text','string','freqlist(0~1e9)');
            obj.handles.textbox8=uicontrol('parent',freqlayout,'style','text','string','DAC output freq settings in SFDR&SNR testing');
            obj.handles.presetbutton=uicontrol('parent',freqlayout,'string','Preset');
            obj.handles.freqlistinputbox=uicontrol('parent',freqlayout,'style','edit',...
                'string',obj.testfreqliststr,'tag','inputbox');
            freqlayout.Heights=[-1 -1 -1];
            freqlayout.Widths=[150 -1];
                %freqlayout.Visible='off';
            obj.handles.textbox7.Visible='off';
            obj.handles.freqlistinputbox.Visible='off';
            obj.handles.presetbutton.Visible='off';
            set(obj.handles.nonpresetbutton,'callback',@(o,e)obj.nonpreset(o,e));
            set(obj.handles.presetbutton,'callback',@(o,e)obj.nonpreset(o,e));
            
            %osclayout
            obj.handles.initoscbutton=uicontrol('parent',osclayout,'string','init osc');
            obj.handles.starttestoscbutton=uicontrol('parent',osclayout,'string','simulate');
            osclayout.Heights=[-1 -1];
            %osclayout.Widths=[-1];
            set(obj.handles.initoscbutton,'callback',@(o,e)obj.initosc(o,e));
            set(obj.handles.starttestoscbutton,'callback',@(o,e)obj.starttestosc(o,e));
            
            %axes
                %axes( 'Parent', hbox, 'ActivePositionProperty', 'outerposition' );
            obj.handles.ha1=axes( 'Parent', axeslayout,'Position',[0.05,0.1,0.4,0.8]);
            obj.handles.ha2=axes( 'Parent', axeslayout,'Position',[0.55,0.1,0.4,0.8]);

%             xlabel(obj.handles.ha1,'fout Hz');
%             ylabel(obj.handles.ha1,'SFDR dBc');
%             ylim(obj.handles.ha1,[-100 0]);
%             title(obj.handles.ha1,'SFDR');
%             xlabel(obj.handles.ha2,'fout Hz');
%             ylabel(obj.handles.ha2,'SNR dBc');
%             title(obj.handles.ha2,'SNR');
            
%             %测试代码
%             surf( obj.handles.ha1, membrane( 1, 15 ) );
%             colorbar( obj.handles.ha1 );
%             theta = 0:360;
%             plot( obj.handles.ha2, theta, sind(theta), theta, cosd(theta) );
%             legend( obj.handles.ha2, 'sin', 'cos', 'Location', 'NorthWestOutside' );
            
            
        end
        
        function nonpreset(obj,o,e) %#ok<INUSD>
            onoff={'on','off'};
            obj.testfreqpreset=1-obj.testfreqpreset;%默认值是1，使用预设
            obj.handles.textbox7.Visible=onoff{obj.testfreqpreset+1};
            obj.handles.freqlistinputbox.Visible=onoff{obj.testfreqpreset+1};
            obj.handles.presetbutton.Visible=onoff{obj.testfreqpreset+1};
            obj.handles.nonpresetbutton.Visible=onoff{2-obj.testfreqpreset};
        end
    end
end
