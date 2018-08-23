function cm = bgy(m)
    % color map

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
  if nargin == 0
      m = 128;
  end
  r= [0.98627450980392,0.979093400801181,0.979487455197132,0.979843980602994,0.974016445287792,...
      0.966148007590133,0.957385620915033,0.938207885304659,0.901615011596036,0.857465738983765,...
      0.808239510858107,0.754948344929370,0.694185114906177,0.624102888467215,0.563457727176892,...
      0.536360952983344,0.528753953194181,0.520042167404596,0.487699768079275,0.443086654016445,...
      0.377592241197554,0.275260383723382,0.159063883617963,0.171267130508117,0.231996626607632,...
      0.258199451823740,0.260349989458149,0.258174151380983,0.251840607210626,0.246552814674257,...
      0.244452877925364,0.239215686274510];

  g = [0.643137254901961,0.657550073792958,0.673286949188278,0.696647691334598,0.720725279359056,...
      0.760978283786633,0.820164452877925,0.877891629770188,0.919291587602783,0.923508328062408,...
      0.911043643263757,0.896175416403120,0.874585705249842,0.846594982078853,0.821134303183639,...
      0.810592452034577,0.807311827956989,0.802445709466582,0.788370229812355,0.771427366645583,...
      0.744195656757327,0.708977440438541,0.664001686696184,0.604756483238457,0.539658444022771,...
      0.479814463419777,0.430697870546068,0.383149905123340,0.346320893948977,0.323255323634830,...
      0.291064726966055,0.270588235294118];
  
  b = [0.274509803921569,0.287606999789163,0.292844191440017,0.305722116803711,0.315918195235083,...
      0.338115117014548,0.368931056293485,0.403845667299178,0.455256166982922,0.511760489141893,...
      0.565448028673835,0.608863588446131,0.629002740881299,0.635665190807506,0.642158971115328,...
      0.679131351465317,0.746514864010120,0.803246890153911,0.852692388783471,0.884157706093190,...
      0.901589711153278,0.908665401644529,0.898798228969007,0.853569470799072,0.791127978072950,...
      0.739321104786000,0.695711574952562,0.649782837866329,0.620282521610795,0.602960151802657,...
      0.580974067046173,0.556862745098039];
  
  x = linspace(0,1,32);
  cm = ones(m,3);
  xi = linspace(0,1,m);
  cm(:,1) = interp1(x,r,xi);
  cm(:,2) = interp1(x,g,xi);
  cm(:,3) = interp1(x,b,xi);
  cm = flipud(cm);
end