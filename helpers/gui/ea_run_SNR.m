function ea_run_SNR(hobj,evt,handles)


dirs=getappdata(handles.leadfigure,'uipatdir');
prefs=ea_prefs;
for pt=1:length(dirs)
    res=ea_run_SNR_pt(dirs{pt});
    if ~exist('allRes','var')
        allRes=res;
    else
        fn=fieldnames(res);
        for field=1:length(fn)
            allRes(pt).(fn{field})=res.(fn{field});
        end
    end
end
save('SNR_metrics','allRes');


function res=ea_run_SNR_pt(directory)

options=ea_getptopts(directory);
[~,presentfiles] = ea_assignpretra(options);
presentfiles=stripstn(presentfiles);
if ~strcmp(directory(end),filesep)
    directory=[directory,filesep];
end
if ~exist([directory,'c6',presentfiles{1}],'file')
    ea_newseg(directory,presentfiles,0,options,1,2)
end

noisemask=ea_load_nii([directory,'c6',presentfiles{1}]);
c1mask=ea_load_nii([directory,'c1',presentfiles{1}]);
c2mask=ea_load_nii([directory,'c2',presentfiles{1}]);
c3mask=ea_load_nii([directory,'c3',presentfiles{1}]);

for fi=1:length(presentfiles)
    thisanat=ea_load_nii([directory,presentfiles{fi}]);
        noise=thisanat.img.*(noisemask.img>0.5); noise=ea_nanstd(noise(:));

    c1signal=thisanat.img.*(c1mask.img>0.5); c1snr=ea_nanmean(c1signal(:))/noise;
    c2signal=thisanat.img.*(c2mask.img>0.5); c2snr=ea_nanmean(c2signal(:))/noise;
    c3signal=thisanat.img.*(c3mask.img>0.5); c3snr=ea_nanmean(c3signal(:))/noise;

    res.(ea_stripex(presentfiles{fi})).c1snr=c1snr;
    res.(ea_stripex(presentfiles{fi})).c2snr=c2snr;
    res.(ea_stripex(presentfiles{fi})).c3snr=c3snr;
end


function presentfiles=stripstn(presentfiles)

[mem,ix]=ismember(presentfiles,{'anat_STN.nii','anat_RN.nii','anat_GPi.nii','anat_GPe.nii'});
presentfiles=presentfiles(~mem);