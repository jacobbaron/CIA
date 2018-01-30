function [odorStrs]=compute_odor_conc(odorSeq,t)
    idx = odorSeq.odorSeqStep(t);
   if idx==0
        odorStrs = {'Water'};
        
   else
       
       odorIdx = odorSeq.seqArr(:,idx);
       numOdors = sum(double(odorIdx));
       odorStrs = cellfun(@(x,y)[x,' ',y],odorSeq.concs(odorIdx),odorSeq.odors(odorIdx),...
           'UniformOutput',false);
       odorStrs = [num2str(numOdors),' odors';odorStrs];
       
   end
end