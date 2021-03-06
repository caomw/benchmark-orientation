%% getKeypoints_SIFT.m --- 
% 
% Filename: getKeypoints_SIFT.m
% Description: Wrapper Function for SIFT
% Author: Kwang Moo Yi, Yannick Verdie
% Maintainer: Kwang Moo Yi, Yannick Verdie
% Created: Tue Jun 16 17:20:35 2015 (+0200)
% Version: 
% Package-Requires: ()
% Last-Updated: Mon Oct 26 14:33:53 2015 (+0100)
%           By: Kwang
%     Update #: 13
% URL: 
% Doc URL: 
% Keywords: 
% Compatibility: 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%% Commentary: 
% 
% 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%% Change Log:
% 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%% Code:


function [feat,desc,metric] = getDescriptors_sGLOH(img_info, kp_file_name, orientation_file_name, p)
    
    %here reject some kp
    listMethodsOK = {'HARRISZ','HARAFF','PT','SIFTFIXED'};
    if (all(~strcmp(kp_file_name,listMethodsOK)) || ~isempty(strfind(orientation_file_name,'GHH')))
        feat = [];
        desc = [];
        metric = '';
        return;
    end

    metric = 'sGLOH';
    methodName = strsplit(mfilename,'_');
    methodName = methodName{end};
    
    param_nameKp =  p.optionalParametersKpName;
    param_nameOrient =  p.optionalParametersOrientName;
    param_nameDesc =  p.optionalParametersDescName;
    
    paramname = [param_nameKp '-' param_nameOrient '-' param_nameDesc];
    
     in = img_info.image_name;
     in = strrep(in, 'image_gray', 'image_color');

    kpf = [img_info.full_feature_prefix '_' kp_file_name '_keypoints_' orientation_file_name '_oriented-' param_nameKp '-' param_nameOrient '-txt'];
    out = [img_info.full_feature_prefix '_' kp_file_name '_keypoints_' orientation_file_name '_oriented_' methodName '_descriptors-' paramname '-txt'];
    

    kpf2 = [img_info.full_feature_prefix '_' kp_file_name '_keypoints_for' methodName '_' orientation_file_name '_oriented-' param_nameKp '-' param_nameOrient '-txt'];
    if ~exist(out, 'file')% || forceRecomputeNoSave

        [feat_out, ~, ~] = loadFeatures(kpf);
        if (strcmp(kp_file_name,'SIFTFIXED')) %kpf -> /2 -> kpf2
            coeffDescriptor = 3;
            coeffTarget  = 7.5;
            [feat_out] = rescaleEllipseAffine(feat_out,coeffTarget/coeffDescriptor);
        end
        saveFeatures(feat_out,kpf2);
        com = originalDescriptor(methodName, in, kpf2, out, p);
        % Re Scale it back
        if (strcmp(kp_file_name,'SIFTFIXED')) %kpf -> /2 -> kpf2
            [feat_out, ~, ~] = loadFeatures(kpf2);
            [feat_out] = rescaleEllipseAffine(feat_out,coeffDescriptor/coeffTarget);
            saveFeatures(feat_out,kpf2);
        end
    end

    if ~exist(kpf2, 'file')
        warning('for file does not exist, not using it');
    else
        kpf = kpf2;
    end    
    
    if ~exist(kpf, 'file')
        error('the keypoints do not exist, abort');
    end
    
   [feat, ~, ~] = loadFeatures(kpf);
    desc = loadDescriptors(out)';
    
    if (size(feat,2) ~= size(desc,2))
        display(com);
        error([methodName ' deleted kp, so now we have a missmatch !']);
    end
    
    if all(sum(feat(7:9,:) == 0))
        %recpmpute, because cannot save it as runDescriptorsOpenCV is not
        %compatible (and the function delete kp, so the kp used are those from this function)
        feat(7,:) = 1./(feat(3,:).*feat(3,:));
        feat(8,:) =  zeros(size(feat(7,:),2),1)';
        feat(9,:) = feat(7,:);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% getKeypoints_SIFT.m ends here
