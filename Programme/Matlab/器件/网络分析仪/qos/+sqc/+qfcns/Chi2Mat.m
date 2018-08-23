function M = CZP(chi)
I = [1,0,0,1];
X = [0,1;1,0];
Y = [0,-1j;1j,0];
Z = [1,0;0,-1];
E = {I,X,Y,Z};
dim = size(chi,1)
switch dim
	case 4
		M = zeros(2,2);
		for ii = 1:4
			for jj = 1:4
				row = 4*(ii-1)+jj;
				col = 4*(kk-1)+nn;
				M = M + chi(row,col)*kron(E{row},E{col}');
			end
		end
	case 16
		M = zeros(4,4);
		for ii = 1:4
			for jj = 1:4
				for kk = 1:4
					for nn = 1:4
						row = 4*(ii-1)+jj;
						col = 4*(kk-1)+nn;
						E1 = kron(E{ii},E{jj});
						E2 = kron(E{kk},E{nn});
						M = M + chi(row,col)*E1;
					end
				end
			end
		end
end

end