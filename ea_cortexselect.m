function varargout = ea_cortexselect(varargin)
% EA_CORTEXSELECT MATLAB code for ea_cortexselect.fig
%      EA_CORTEXSELECT, by itself, creates a new EA_CORTEXSELECT or raises the existing
%      singleton*.
%
%      H = EA_CORTEXSELECT returns the handle to a new EA_CORTEXSELECT or the handle to
%      the existing singleton*.
%
%      EA_CORTEXSELECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EA_CORTEXSELECT.M with the given input arguments.
%
%      EA_CORTEXSELECT('Property','Value',...) creates a new EA_CORTEXSELECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ea_cortexselect_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ea_cortexselect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ea_cortexselect

% Last Modified by GUIDE v2.5 23-Nov-2017 12:59:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ea_cortexselect_OpeningFcn, ...
    'gui_OutputFcn',  @ea_cortexselect_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ea_cortexselect is made visible.
function ea_cortexselect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ea_cortexselect (see VARARGIN)

% Choose default command line output for ea_cortexselect
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ea_cortexselect wait for user response (see UIRESUME)
% uiwait(handles.cortexselect);

% cswin = ea_cortexselect(cortex, annot, atlases, colorindex, struct_names, options, resultfig);

cortex=varargin{1};
annot=varargin{2};
atlases=varargin{3};
colorindex=varargin{4};
struct_names=varargin{5};
options=varargin{6};
resultfig=varargin{7};

if ~isfield(options,'native')
    options.native=0;
end

set(handles.cortexselect,'Visible',options.d3.verbose); % set invisible if called from lead group

movegui(hObject,'southeast');

% ea_listcortatlas(options,handles,options.native);
 set(handles.atlaspopup,'String',atlases);

% [~,handles.atlaspopup.Value]=ismember(options.atlasset,handles.atlaspopup.String);

setappdata(handles.cortexselect,'handles',handles);
setappdata(handles.cortexselect,'atlases',atlases);
setappdata(handles.cortexselect,'annot',annot);
setappdata(handles.cortexselect,'struct_names',struct_names);
setappdata(handles.cortexselect,'options',options);
setappdata(handles.cortexselect,'resultfig',resultfig);

axis off
ea_createpcmenu(handles);
set(handles.structpopup,'String',struct_names);
setappdata(handles.cortexselect,'treeinit',1);
setuptree([{handles}, varargin])


function setuptree(varargin)

% IO handling
handles=varargin{1}{1};

ea_busyaction('on',handles.cortexselect,'atlcontrol');

cortex=varargin{1}{2};
annot=varargin{1}{3};
atlases=varargin{1}{4};
colorindex=varargin{1}{5};
struct_names=varargin{1}{6};
options=varargin{1}{7};
resultfig=varargin{1}{8};

setappdata(handles.cortexselect,'annot',annot);
setappdata(handles.cortexselect,'atlases',atlases);
setappdata(handles.cortexselect,'colorindex',colorindex);
setappdata(handles.cortexselect,'struct_names',struct_names);

% try
%     if ~isfield(annot,'subgroups')
%         annot.subgroups(1).label='Structures';
%         annot.subgroups(1).entries=1:length(atlases.names);
%     end
% catch
%     keyboard
% end

cortchecks=cell(length(struct_names),1);
import com.mathworks.mwswing.checkboxtree.*
if handles.structpopup.Value>length(handles.structpopup.String)
    handles.structpopup.Value=1;
end

if handles.togglepopup.Value>length(handles.togglepopup.String)
    handles.togglepopup.Value=1;
end

switch handles.structpopup.String{handles.structpopup.Value}
    case 'NIfTI filenames'  % use atlases.names
        uselabelname = 0;
    otherwise  % use atlases.labels
        [~,uselabelname] = ismember(handles.structpopup.String{handles.structpopup.Value},struct_names);
        if uselabelname == 0
            uselabelname = 1;
        end
end


for s = 1:2  % side 1=Right, 2=Left
    if s==1
        h.sg{s} = DefaultCheckBoxNode('Right');
    elseif s==2
        h.sg{s} = DefaultCheckBoxNode('Left');
    end
    for node=1:length(struct_names)
        thisstruct=struct_names{node};
        
        color = annot(s).colortable.table(node,1:3);
        color = sprintf('rgb(%d,%d,%d)', color(1),color(2),color(3));
        
        structlabel = ['<HTML><BODY>' ...
            '<FONT color=',color,' bgcolor=',color,'>ico</FONT>' ...
            '<FONT color="black">&nbsp;&nbsp;',thisstruct,'</FONT>' ...
            '</BODY></HTML>'];
        h.sgsub{s}{node}=DefaultCheckBoxNode(structlabel,true);
        h.sg{s}.add(h.sgsub{s}{node});
       
         cortchecks{node}=...
            [cortchecks{node},h.sgsub{s}{node}];

    end
end
    
    ea_cleanpriortree(handles);
    
    % Create a standard MJTree:
    jTree = com.mathworks.mwswing.MJTree(h.sg{1});
    
    % Now present the CheckBoxTree:
    jCheckBoxTree = CheckBoxTree(jTree.getModel);
    
    jScrollPane = com.mathworks.mwswing.MJScrollPane(jCheckBoxTree);
    treeinit=getappdata(handles.cortexselect,'treeinit');
    setappdata(handles.cortexselect,'treeinit',0);
    
    atlN=length(struct_names);
    height=(atlN+1.5)*18;
    norm=360; % max height if full size figure shown.
    if height>360
        height=360;
    end
    if height<100
        height=100;
    end
    
    [jComp,hc] = javacomponent(jScrollPane,[10,5,285,height],handles.cortexselect);
    setappdata(handles.cortexselect,'uitree',jComp);
    
    ea_busyaction('del',handles.cortexselect,'atlcontrol');
    
    h.uselabelname = uselabelname;
    set(jCheckBoxTree, 'MouseReleasedCallback', {@mouseReleasedCallback, h})
    setappdata(handles.cortexselect,'h',h);
    setappdata(handles.cortexselect,'jtree',jCheckBoxTree);
    %sels=ea_storeupdatemodel(jCheckBoxTree,h);
    
    if treeinit
        if handles.structpopup.Value>length(handles.structpopup.String)
            handles.structpopup.Value=1;
        end
        if handles.togglepopup.Value>length(handles.togglepopup.String)
            handles.togglepopup.Value=1;
        end
        %handles.cortexselect.Position(2)=handles.cortexselect.Position(2)-(450);
        handles.cortexselect.Position(4)=(534-(360-height));
        
        handles.cortstructxt.Position(2)=handles.cortexselect.Position(4)-25;
        
        handles.atlaspopup.Position(2)=handles.cortexselect.Position(4)-75;
        handles.atlasstatic.Position(2)=handles.atlaspopup.Position(2)+28;
        
        handles.togglepopup.Position(2)=handles.cortexselect.Position(4)-120;
        handles.togglestatic.Position(2)=handles.togglepopup.Position(2)+28;
        
        handles.structpopup.Position(2)=handles.cortexselect.Position(4)-165;
        handles.cortexstatic.Position(2)=handles.structpopup.Position(2)+28;
        
        set(0,'CurrentFigure',handles.cortexselect);
        axis off
        movegui(handles.cortexselect,'southeast');
    end


function ea_cleanpriortree(handles)

jComp=getappdata(handles.cortexselect,'uitree');
if ~isempty(jComp)
    delete(jComp);
end


function tf=bin2bool(t)
if t
    tf=true;
else
    tf=false;
end

function tf=onoff2bool(t)
switch t
    case 'on'
        tf=true;
    case 'off'
        tf=false;
end


function ea_showhideatlases(jtree,h)

sels=ea_storeupdatemodel(jtree,h);
for branch=1:length(sels.branches)
    for leaf=1:length(sels.leaves{branch})
        if ~isempty(sels.sides{branch}{leaf}) % has side children
            for side=1:length(sels.sides{branch}{leaf})

                sidec=getsidec(length(sels.sides{branch}{leaf}),side);

                [ixs,ixt]=ea_getsubindex(h.sgsub{branch}{leaf}.toString,sidec,h.atlassurfs,h.togglebuttons,h.uselabelname,h.atlases);
                if strcmp(sels.sides{branch}{leaf}{side},'selected')
                    if ~strcmp(h.atlassurfs(ixs).Visible,'on')
                        h.atlassurfs(ixs).Visible='on';
                        h.togglebuttons(ixt).State='on';
                    end

                    if strcmp(h.labelbutton.State, 'on')
                        h.atlaslabels(ixs).Visible='on';
                    end
                elseif strcmp(sels.sides{branch}{leaf}{side},'not selected')
                    if ~strcmp(h.atlassurfs(ixs).Visible,'off')
                        h.atlassurfs(ixs).Visible='off';
                        h.togglebuttons(ixt).State='off';
                    end

                    if strcmp(h.labelbutton.State, 'on')
                        h.atlaslabels(ixs).Visible='off';
                    end
                end
            end

        else
            keyboard
        end
    end

end


function sidec=getsidec(sel,side)

if sel==2
    switch side
        case 1
            sidec='_right';
        case 2
            sidec='_left';
    end
elseif sel==1
    sidec='_midline';
end


% Set the mouse-press callback
function mouseReleasedCallback(jtree, eventData, h)

clickX = eventData.getX;
clickY = eventData.getY;
treePath = jtree.getPathForLocation(clickX, clickY);

oldselstate=getappdata(jtree,'selectionstate');
newselstate=ea_storeupdatemodel(jtree,h);
if ~isequal(oldselstate,newselstate)
    ea_showhideatlases(jtree,h);
end


% --- Outputs from this function are returned to the command line.
function varargout = ea_cortexselect_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in togglepopup.
function togglepopup_Callback(hObject, eventdata, handles)
% hObject    handle to togglepopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns togglepopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from togglepopup

%pcmenu=getappdata(handles.togglepopup,'uimenu');

%showcontextmenu(hObject,pcmenu);

presetactions=getappdata(handles.togglepopup,'presetactions');
ea_makeselection([],[],handles,presetactions{handles.togglepopup.Value});


function ea_createpcmenu(handles)
annot=getappdata(handles.cortexselect,'annot');
struct_names=getappdata(handles.cortexselect,'struct_names');

def.presets(1).label='Show all structures';
def.presets(1).show=1:length(struct_names);
def.presets(1).hide=[];
def.presets(1).default='absolute';
def.presets(2).label='Hide all structures';
def.presets(2).show=[];
def.presets(2).hide=1:length(struct_names);
def.presets(2).default='absolute';
prescell=cell(0);
presetactions=cell(0);
% add defaults:
for ps=1:length(def.presets)
    prescell{end+1}=def.presets(ps).label;
    presetactions{end+1}=def.presets(ps);
    %    uimenu(pcmenu, 'Label',,'Callback',{@ea_makeselection,handles,def.togglepopup(ps)});
end

% add from atlas index:
if isfield(annot,'presets')
    for ps=1:length(annot.presets)
        prescell{end+1}=annot.presets(ps).label;
        presetactions{end+1}=annot.presets(ps);

        %        uimenu(pcmenu, 'Label',atlases.togglepopup(ps).label,'Callback',{@ea_makeselection,handles,atlases.togglepopup(ps)});
    end
end
% add from prefs:
prefs=ea_prefs;
options=getappdata(handles.cortexselect,'options');
% if isfield(prefs.machine.atlaspresets,getridofspaces(options.atlasset))
%     for ps=1:length(prefs.machine.atlaspresets.(getridofspaces(options.atlasset)).presets)
%         try
%             prescell{end+1}=prefs.machine.atlaspresets.(getridofspaces(options.atlasset)).presets{ps}.label;
%             presetactions{end+1}=prefs.machine.atlaspresets.(getridofspaces(options.atlasset)).presets{ps};
% 
%             %        uimenu(pcmenu, 'Label',prefs.machine.atlaspresets.(getridofspaces(options.atlasset)).togglepopup{ps}.label,'Callback',{@ea_makeselection,handles,prefs.machine.atlaspresets.(getridofspaces(options.atlasset)).togglepopup{ps}});
%         catch
%             keyboard
%         end
%     end
% end

% add save prefs:
%uimenu(pcmenu,'Label','Save current selection as preset...','Callback',{@ea_saveselection,handles,options});
handles.togglepopup.String=prescell;
handles.togglepopup.Value=1;

if isfield(annot,'defaultset')
    if length(handles.togglepopup.String)>2 % custom sets available
        handles.togglepopup.Value=annot.defaultset+2;
    end
end
setappdata(handles.togglepopup,'presetactions',presetactions);
%setappdata(handles.togglepopup,'uimenu',pcmenu);

function ea_saveselection(~,~,handles,options)
ea_busyaction('on',handles.cortexselect,'atlcontrol');

jtree=getappdata(handles.cortexselect,'jtree');
h=getappdata(handles.cortexselect,'h');
sels=ea_storeupdatemodel(jtree,h);
atlases=getappdata(handles.cortexselect,'atlases');
pres.default='absolute';
pres.show=[];
pres.hide=[];
[~,atlases.names]=cellfun(@fileparts,atlases.names,'Uniformoutput',0);
[~,atlases.names]=cellfun(@fileparts,atlases.names,'Uniformoutput',0);

for branch=1:length(sels.branches)
    for leaf=1:length(sels.leaves{branch})
        for side=1:length(sels.sides{branch}{leaf})

            sidec=getsidec(length(sels.sides{branch}{leaf}),side);

            %[ixs,ixt]=getsubindex(h.sgsub{branch}{leaf},sidec,h.atlassurfs,h.togglebuttons);

            [~,ix]=ismember(char(h.sgsub{branch}{leaf}),atlases.names);
            if strcmp(sels.sides{branch}{leaf}{side},'selected')
                pres.show=[pres.show,ix];


            elseif strcmp(sels.sides{branch}{leaf}{side},'not selected')
                pres.hide=[pres.hide,ix];
            end
        end

    end
end

try WinOnTop(handles.cortexselect,false); end

tag=inputdlg('Please enter a name for the preset:','Preset name');
pres.label=tag{1};
try WinOnTop(handles.cortexselect,true); end


prefs=ea_prefs;
machine=prefs.machine;

if ~isfield(machine.atlaspresets,getridofspaces(options.atlasset))
    machine.atlaspresets.(getridofspaces(options.atlasset)).presets{1}.default=pres.default;
    machine.atlaspresets.(getridofspaces(options.atlasset)).presets{1}.show=pres.show;
    machine.atlaspresets.(getridofspaces(options.atlasset)).presets{1}.hide=pres.hide;
    machine.atlaspresets.(getridofspaces(options.atlasset)).presets{1}.label=pres.label;

else

    clen=length(machine.atlaspresets.(getridofspaces(options.atlasset)).presets);
    machine.atlaspresets.(getridofspaces(options.atlasset)).presets{clen+1}.default=pres.default;
    machine.atlaspresets.(getridofspaces(options.atlasset)).presets{clen+1}.show=pres.show;
    machine.atlaspresets.(getridofspaces(options.atlasset)).presets{clen+1}.hide=pres.hide;
    machine.atlaspresets.(getridofspaces(options.atlasset)).presets{clen+1}.label=pres.label;
end

save([ea_gethome,'.ea_prefs.mat'],'machine');

% refresh content menu.
ea_createpcmenu(handles)

ea_busyaction('off',handles.cortexselect,'atlcontrol');


function str=getridofspaces(str)
str=strrep(str,'(','');
str=strrep(str,')','');
str=strrep(str,' ','');
str=strrep(str,'-','');


function ea_makeselection(~,~,handles,preset)

ea_busyaction('on',handles.cortexselect,'atlcontrol');

h=getappdata(handles.cortexselect,'h');
jtree=getappdata(handles.cortexselect,'jtree');
atlases=getappdata(handles.cortexselect,'atlases');
onatlasnames=atlases.names(preset.show);
offatlasnames=atlases.names(preset.hide);
% get rid of file extensions:
[~,onatlasnames]=cellfun(@fileparts,onatlasnames,'Uniformoutput',0);
[~,onatlasnames]=cellfun(@fileparts,onatlasnames,'Uniformoutput',0);
[~,offatlasnames]=cellfun(@fileparts,offatlasnames,'Uniformoutput',0);
[~,offatlasnames]=cellfun(@fileparts,offatlasnames,'Uniformoutput',0);

% iterate through jTree to set selection according to preset:
sels=ea_storeupdatemodel(jtree,h);
for branch=1:length(sels.branches)
    for leaf=1:length(sels.leaves{branch})
        for side=1:length(sels.sides{branch}{leaf})

            sidec=getsidec(length(sels.sides{branch}{leaf}),side);
            [ixs,ixt]=ea_getsubindex(h.sgsub{branch}{leaf}.toString,sidec,h.atlassurfs,h.togglebuttons,h.uselabelname,h.atlases);

            if ismember(char(h.sgsubfi{branch}{leaf}),onatlasnames)
                h.atlassurfs(ixs).Visible='on';
                if strcmp(h.labelbutton.State, 'on')
                    h.atlaslabels(ixs).Visible='on';
                end
                h.togglebuttons(ixt).State='on';
            elseif ismember(char(h.sgsubfi{branch}{leaf}),offatlasnames)
                h.atlassurfs(ixs).Visible='off';
                h.atlaslabels(ixs).Visible='off';
                h.togglebuttons(ixt).State='off';
            else % not explicitly mentioned
                switch preset.default
                    case 'absolute'
                        h.atlassurfs(ixs).Visible='off';
                        h.atlaslabels(ixs).Visible='off';
                        h.togglebuttons(ixt).State='off';
                    case 'relative'
                        % leave state as is.
                end
            end
        end

    end
end
ea_busyaction('off',handles.cortexselect,'atlcontrol');

ea_synctree(handles)


% --- Executes during object creation, after setting all properties.
function togglepopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to togglepopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in atlaspopup.
function atlaspopup_Callback(hObject, eventdata, handles)
% hObject    handle to atlaspopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns atlaspopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from atlaspopup


ea_busyaction('on',handles.cortexselect,'atlcontrol');

% retrieve necessary info from cortexselect figure:
resultfig=getappdata(handles.cortexselect,'resultfig');
options=getappdata(handles.cortexselect,'options');

% surfaces
atlassurfs=getappdata(resultfig,'atlassurfs');
for atl=1:numel(atlassurfs)
    delete(atlassurfs(atl))
end

% labels
atlaslabels=getappdata(resultfig,'atlaslabels');
for atl=1:numel(atlaslabels)
    delete(atlaslabels(atl))
end

elstruct=getappdata(resultfig,'elstruct');
options.atlasset=get(handles.atlaspopup,'String'); %{get(handles.atlaspopup,'Value')}
options.atlasset=options.atlasset{get(handles.atlaspopup,'Value')};
options.atlassetn=get(handles.atlaspopup,'Value');
setappdata(resultfig,'options',options); % update options in resultfig for VAT model
[atlases,colorbuttons,atlassurfs,atlaslabels]=ea_showatlas(resultfig,elstruct,options);
setappdata(handles.cortexselect,'atlases',atlases);
setappdata(handles.cortexselect,'treeinit',1);
labelbutton = getappdata(resultfig,'labelbutton');

setuptree({handles,colorbuttons,atlassurfs,atlases,labelbutton,atlaslabels});
ea_createpcmenu(handles);
ea_busyaction('off',handles.cortexselect,'atlcontrol');


% --- Executes during object creation, after setting all properties.
function atlaspopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to atlaspopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in structpopup.
function structpopup_Callback(hObject, eventdata, handles)
% hObject    handle to structpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns structpopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from structpopup


colorbuttons=getappdata(handles.cortexselect,'colorbuttons');
atlassurfs=getappdata(handles.cortexselect,'atlassurfs');
atlases=getappdata(handles.cortexselect,'atlases');
labelbutton=getappdata(handles.cortexselect,'labelbutton');
atlaslabels=getappdata(handles.cortexselect,'atlaslabels');

setuptree({handles,colorbuttons,atlassurfs,atlases,labelbutton,atlaslabels});


% --- Executes during object creation, after setting all properties.
function structpopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to structpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end