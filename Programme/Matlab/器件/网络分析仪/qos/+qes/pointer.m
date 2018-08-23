classdef pointer < handle
    % POINTER handle class acting as struct
    %a=pointer;
    %b=a;
    %b.c=1;
    % >>a
    % 
    % a = 
    % 
    %     c: 1
    %
    %d(10,1)=pointer; ok
    %f{2,1}=pointer; ok
    %
    %g=struct('a',1,'b',2)
    %h=pointer(g)
    %i=pointer(h)
    %a.copy(g)
    %j=h.struct()
    %isa(j,'struct')
    
    % zhaouv https://zhaouv.github.io/
    
    properties (Access = private)
        handles
    end
    
    
    methods
        function obj=pointer(struct_)
            if nargin
                obj=pointer;
                copy(obj,struct_);
            end
        end
        
        function obj=copy(obj,struct_)
            if ~isa(struct_,'pointer')
                struct_=struct(struct_);
            end
            if ~isa(struct_,'struct')
                error('not a struct or pointer')
            end
            names = fieldnames(struct_);
            for i=1:length(names)
               name = char(names(i));
               eval(['obj.handles.' name '=struct_.' name ';'])
            end
        end
        
        function handles=struct(obj)
            handles=obj.handles;
        end
        
        function disp(objs)
            if size(objs,1)~=1 || size(objs,2)~=1 || size(size(objs),2)~=2
                sstr=sprintf('%d   ',size(objs));
                disp(['size: ' sstr 'pointer Array'])
                if  numel(objs)<=12
                    for i=1:numel(objs)
                        fprintf('----%d----\n',i)
                        s.type='.';s.subs='handles';
                        disp(builtin('subsref',objs(i),s))
                    end
                end
            else
                s.type='.';s.subs='handles';
                disp(builtin('subsref',objs,s))
            end
        end

        function obj=subsasgn(obj,s,val)
            if size(s,1)~=1 || size(s,2)~=1
                sobj=obj;
                obj=subsasgn(subsref(obj,s(1:end-1)),s(end),val); %#ok<NASGU>
                obj=sobj;
            else
                switch s.type
                    case '.'
                        obj.handles=builtin('subsasgn',obj.handles,s,val);
                    otherwise
                        if ~isempty(obj)
                            obj=builtin('subsasgn',obj,s,val);
                        else
                            switch s.type
                                case '{}'
                                    obj=cell(s.subs);
                                    obj(s.subs)=val;
                                case '()'
                                    n=size(s.subs,2);num=1;forreshape=[];
                                    for i=1:n
                                        num=num * s.subs{i};
                                    end
                                    for i=1:num-1
                                        forreshape=[forreshape pointer()]; %#ok<AGROW>
                                    end
                                    forreshape=[forreshape val];
                                    obj=reshape(forreshape,cell2mat(s.subs));
                            end
                        end
                end
            end
        end
        function sref=subsref(obj,s)
            if size(s,1)~=1 || size(s,2)~=1
                if ismember(s(1).subs,{'copy'})
                    sref=copy(obj,s(2).subs{1});
                elseif ismember(s(1).subs,{'struct'})
                    sref=struct(obj);
                else
                tobj=subsref(obj,s(1));
                sref=subsref(tobj,s(2:end));
                end
            else
                switch s.type
                    case '.'
                        sref=builtin('subsref',obj.handles,s);
                    otherwise
                        sref=builtin('subsref',obj,s);
                end
            end
        end
    end
end
%%
%{
% lib.pointer class
% libpointer

x=[1 4 5];
xPtr=libpointer('doublePtr',x);
get(xPtr,'value')
set(xPtr,'value',[1 2 3;4 5 6]);
get(xPtr,'value')
% not useful X no changed
%}
%%
%objectArray(1,5)=pointer();
%objectArray(3).a=1

%apointer=pointer();
%a=uix.Grid('parent',figure(),'UserData',apointer);
%function SelectDataCallback(src,entdata)
%apointer = get(get(src,'Parent'),'UserData');
%end
