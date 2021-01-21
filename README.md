# Neurofeedback-Investigations-of-Integrative-Decision-Making
Scripts associated with the Neurofeedback Investigations of Integrative Decision Making Experiment

The folder "/NF_investigations_of_integrative_decision_making_Experimental_Task" contains all the matlab scripts used to deliver the experimental task. 
There were several main scripts used to deliver different parts of the protocol. 

1. DotFields_StripeAmp.m - The script delivers a short version of the task without coherent motion, used to assess for baseline differences in SSVEPs between the two orientations. 
2. DotFields_Staircase_V1.m - The staircase procedure used to set each participant's motion coherence threshold. 
3. readAmplifiers_AttnDecNF.m - This script interfaces with the EEG amplifier, reads data and writes it to a ring buffer in real-time, and ultimately saves the data to disk. 
4. SSVEP_Stream_V4.m - This script reads the EEG data from the ring buffer, performs the normalised difference calculation on real-time SSVEPs, and writes the result to a second ring buffer. 
5. Dotfields_V8.m - This script presents the main experimental task. The motion coherence is varied in real-time based on the normalised SSVEP difference read from the second ring buffer. 

The remaining files in the folder support the main scripts listed here. 
