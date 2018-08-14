function aCost=CalculateCost(aFilename)

% Read the touchstone file and get the S21 and S31 data
[~, Data] = TouchstoneRead(aFilename);
S21=permute(Data(2,1,:),[3 2 1]);
S31=permute(Data(3,1,:),[3 2 1]);

% Convert S21 and S31 to dB
S21dB=20*log10(abs(S21));
S31dB=20*log10(abs(S31));

% Get angle of S21 and S31 in degrees
S21ang=angle(S21)*180/pi;
S31ang=angle(S31)*180/pi;

% Calculate the errors
Err3db2=abs(S21dB+3)*10;
Err3db3=abs(S31dB+3)*10;
Err90deg2=abs(S21ang+90);
Err90deg3=abs(S31ang+90);

% Calculate the cost
aCost=Err3db2+Err3db3+Err90deg2+Err90deg3;

end