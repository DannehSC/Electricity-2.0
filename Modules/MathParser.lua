--[[
	Math Parser by Hunter200165
]]

local HMathP = {};
local bit = require('bit') or require('bit32');

HMathP.NumberMask = '%-?%d+%.?%d*';

HMathP.ExponentMask = HMathP.NumberMask .. '%s-%*%*%s-' .. HMathP.NumberMask;

HMathP.DivMask = HMathP.NumberMask .. '%s+div%s+' .. HMathP.NumberMask;
HMathP.ModMask = HMathP.NumberMask .. '%s+mod%s+' .. HMathP.NumberMask;
HMathP.DivMaskC = HMathP.NumberMask .. '%s-%/%/%s-' .. HMathP.NumberMask;
HMathP.ModMaskC = HMathP.NumberMask .. '%s-%%%s-' .. HMathP.NumberMask;

HMathP.MultiplyMask = HMathP.NumberMask .. '%s-%*%s-' .. HMathP.NumberMask;
HMathP.DivideMask = HMathP.NumberMask .. '%s-%/%s-' .. HMathP.NumberMask;
HMathP.AddMask = HMathP.NumberMask .. '%s-%+%s-' .. HMathP.NumberMask;
HMathP.SubtractMask = HMathP.NumberMask .. '%s-%-%s-' .. HMathP.NumberMask;

HMathP.ANDMask = HMathP.NumberMask .. '%s+and%s+' .. HMathP.NumberMask;
HMathP.ORMask = HMathP.NumberMask .. '%s+or%s+' .. HMathP.NumberMask;
HMathP.XORMask = HMathP.NumberMask .. '%s+xor%s+' .. HMathP.NumberMask;
HMathP.SHLMask = HMathP.NumberMask .. '%s+shl%s+' .. HMathP.NumberMask;
HMathP.SHRMask = HMathP.NumberMask .. '%s+shr%s+' .. HMathP.NumberMask;
HMathP.EqualMask = HMathP.NumberMask .. '%s-%=%s-' .. HMathP.NumberMask;
HMathP.NOTMask = 'not%s+' .. HMathP.NumberMask;

HMathP.ANDMaskC = HMathP.NumberMask .. '%s-&&%s-' .. HMathP.NumberMask;
HMathP.ORMaskC = HMathP.NumberMask .. '%s-||%s-' .. HMathP.NumberMask;
HMathP.XORMaskC = HMathP.NumberMask .. '%s-^%s-' .. HMathP.NumberMask;
HMathP.SHLMaskC = HMathP.NumberMask .. '%s-<<%s-' .. HMathP.NumberMask;
HMathP.SHRMaskC = HMathP.NumberMask .. '%s->>%s-' .. HMathP.NumberMask;
HMathP.EqualMaskC = HMathP.NumberMask .. '%s-%=%=%s-' .. HMathP.NumberMask;
HMathP.NOTMaskC = '!%s-' .. HMathP.NumberMask;

HMathP.FunctionMask = '%w[%w%d_]*%b[]';

function HMathP.ExtractNumbers(s)
	local Arr = {};
	for num in s:gmatch(HMathP.NumberMask) do 
		table.insert(Arr, tonumber(num) or error('Could not transform number: ' .. num));
	end;
	return Arr;
end;

function HMathP.GetBits(num, bits)
	return (bit.band(num, math.pow(2, bits) - 1));
end;

function HMathP.FUNC(str)
	return str:gsub(HMathP.FunctionMask, 
	function(str)
		local name = '';
		for word in str:gmatch('%w+') do 
			name = word;
			break;
		end;
		local equat = '';
		local Arr = {};
		for equat in str:gmatch('%b[]') do 
			equat = equat:sub(2, -2);
			
			local arg = '';
			local opd = 0;
			while equat:len() > 0 do
				local chr = equat:sub(1, 1);
				equat = equat:sub(2);
				if ((chr == ',') or (chr == ';')) and (opd == 0) then 
					table.insert(Arr, HMathP.ProcessEquation(arg));
					arg = '';
				else
					if (chr == '[') then 
						opd = opd + 1; 
						arg = arg .. chr;
					elseif (chr == ']') then 
						opd = opd - 1;
						arg = arg .. chr;
					else
						arg = arg .. chr;					
					end;
				end;
			end;
			
			table.insert(Arr, HMathP.ProcessEquation((arg == '') and '0' or arg));
			break;
		end;
		local Args = Arr;
		
		if name == 'sqrt' then 
			return math.sqrt(Args[1]);
		elseif name == 'pow' then 
			return math.pow(Args[1], Args[2]);
		elseif name == 'abs' then 
			return math.abs(Args[1]);
		elseif name == 'sin' then 
			return math.sin(Args[1]);
		elseif name == 'cos' then 
			return math.cos(Args[1]);
		elseif name == 'tan' then 
			return math.tan(Args[1]);
		elseif name == 'log' then 
			return math.log(Args[1]);
		elseif name == 'log10' then 
			return math.log10(Args[1]);
		elseif name == 'pi' then 
			return math.pi;
		elseif name == 'floor' then 
			return math.floor(Args[1]);
		elseif name == 'ceil' then 
			return math.ceil(Args[1]);
		elseif name == 'rad' then 
			return math.rad(Args[1]);
		elseif name == 'deg' then 
			return math.deg(Args[1]);
		elseif name == 'bits' then 
			return HMathP.GetBits(Args[1], Args[2]);
		elseif name == 'bit' then 
			return HMathP.GetBits(Args[1], 1);
		elseif name == 'byte' then 
			return HMathP.GetBits(Args[1], 8);
		elseif name == 'word' then 
			return HMathP.GetBits(Args[1], 16);
		elseif name == 'int' then 
			return HMathP.GetBits(Args[1], 32);
		else
			error ('Unknown function: ' .. name);
		end;
	end);
end;

function HMathP.DIV(str)
	return str:gsub(HMathP.DivMask,
		function(s)
			local Arr = HMathP.ExtractNumbers(s);
			return (math.floor(Arr[1] / Arr[2]));
		end);
end;

function HMathP.MOD(str)
	return str:gsub(HMathP.ModMask,
		function(s)
			local Arr = HMathP.ExtractNumbers(s);
			return (Arr[1] % Arr[2]);
		end);
end;

function HMathP.DIVC(str)
	return str:gsub(HMathP.DivMaskC,
		function(s)
			local Arr = HMathP.ExtractNumbers(s);
			return (math.floor(Arr[1] / Arr[2]));
		end);
end;

function HMathP.EXP(str)
	return str:gsub(HMathP.ExponentMask,
		function(s)
			local Arr = HMathP.ExtractNumbers(s);
			return (math.pow(Arr[1], Arr[2]));
		end);
end;

function HMathP.MODC(str)
	return str:gsub(HMathP.ModMaskC,
		function(s)
			local Arr = HMathP.ExtractNumbers(s);
			return (Arr[1] % Arr[2]);
		end);
end;

function HMathP.AND(str)
	return str:gsub(HMathP.ANDMask,
		function(s)
			local Arr = HMathP.ExtractNumbers(s);
			return (bit.band(Arr[1], Arr[2]));
		end);
end;

function HMathP.OR(str)
	return str:gsub(HMathP.ORMask,
		function(s)
			local Arr = HMathP.ExtractNumbers(s);
			return (bit.bor(Arr[1], Arr[2]));
		end);
end;

function HMathP.XOR(str)
	return str:gsub(HMathP.XORMask,
		function(s)
			local Arr = HMathP.ExtractNumbers(s);
			return (bit.bxor(Arr[1], Arr[2]));
		end);
end;

function HMathP.NOT(str)
	return str:gsub(HMathP.NOTMask,
		function(s)
			local Arr = HMathP.ExtractNumbers(s);
			return (bit.bnot(Arr[1]));
		end);
end;

function HMathP.SHL(str)
	return str:gsub(HMathP.SHLMask,
		function(s)
			local Arr = HMathP.ExtractNumbers(s);
			return (bit.lshift(Arr[1], Arr[2]));
		end);
end;

function HMathP.SHR(str)
	return str:gsub(HMathP.SHRMask,
		function(s)
			local Arr = HMathP.ExtractNumbers(s);
			return (bit.rshift(Arr[1], Arr[2]));
		end);
end;

function HMathP.EQUAL(str)
	return str:gsub(HMathP.EqualMask,
		function(s)
			local Arr = HMathP.ExtractNumbers(s);
			return ((Arr[1] == Arr[2]) and 1 or 0);
		end);
end;

function HMathP.ANDC(str)
	return str:gsub(HMathP.ANDMaskC,
		function(s)
			local Arr = HMathP.ExtractNumbers(s);
			return (bit.band(Arr[1], Arr[2]));
		end);
end;

function HMathP.ORC(str)
	return str:gsub(HMathP.ORMaskC,
		function(s)
			local Arr = HMathP.ExtractNumbers(s);
			return (bit.bor(Arr[1], Arr[2]));
		end);
end;

function HMathP.XORC(str)
	return str:gsub(HMathP.XORMaskC,
		function(s)
			local Arr = HMathP.ExtractNumbers(s);
			return (bit.bxor(Arr[1], Arr[2]));
		end);
end;

function HMathP.NOTC(str)
	return str:gsub(HMathP.NOTMaskC,
		function(s)
			local Arr = HMathP.ExtractNumbers(s);
			return (bit.bnot(Arr[1]));
		end);
end;

function HMathP.SHLC(str)
	return str:gsub(HMathP.SHLMaskC,
		function(s)
			local Arr = HMathP.ExtractNumbers(s);
			return (bit.lshift(Arr[1], Arr[2]));
		end);
end;

function HMathP.SHRC(str)
	return str:gsub(HMathP.SHRMaskC,
		function(s)
			local Arr = HMathP.ExtractNumbers(s);
			return (bit.rshift(Arr[1], Arr[2]));
		end);
end;

function HMathP.EQUALC(str)
	return str:gsub(HMathP.EqualMaskC,
		function(s)
			local Arr = HMathP.ExtractNumbers(s);
			return ((Arr[1] == Arr[2]) and 1 or 0);
		end);
end;

function HMathP.Multiply(str)
	return str:gsub(HMathP.MultiplyMask,
		function(s)
			local Arr = HMathP.ExtractNumbers(s);
			return (Arr[1] * Arr[2]);
		end);
end;

function HMathP.Divide(str)
	return str:gsub(HMathP.DivideMask,
		function(s)
			local Arr = HMathP.ExtractNumbers(s);
			return (Arr[1] / Arr[2]);
		end);
end;

function HMathP.Add(str)
	return str:gsub(HMathP.AddMask,
		function(s)
			local Arr = HMathP.ExtractNumbers(s);
			return (Arr[1] + Arr[2]);
		end);
end;

function HMathP.Subtract(str)
	return str:gsub(HMathP.SubtractMask,
		function(s)
			local Arr = HMathP.ExtractNumbers(s);
			return (Arr[1] - Arr[2]);
		end);
end;

function HMathP.Calculate(str)
	local num = str;
	local Arr = 
	{
		HMathP.FUNC;
		
		HMathP.NOT;
		HMathP.NOTC;
		
		HMathP.AND;
		HMathP.ANDC;
		
		HMathP.OR;
		HMathP.ORC;
		
		HMathP.XOR;
		HMathP.XORC;
		
		HMathP.SHL;
		HMathP.SHLC;
		HMathP.SHR;
		HMathP.SHRC;
		
		HMathP.EXP;
		
		HMathP.DIV;
		HMathP.DIVC;
		HMathP.MOD;
		HMathP.MODC;
		
		HMathP.Multiply;
		HMathP.Divide;
		HMathP.Add;
		HMathP.Subtract;
		
		HMathP.EQUAL;
		HMathP.EQUALC;
	};
	for i = 1, #Arr do 
		repeat
		num, count = Arr[i](num);
		until (count == 0) or (not count);
	end;
	return tonumber(num) or error('Invalid number: ' .. num);
end;

function HMathP.ProcessEquation(equa)
	local frms = equa:gsub('%b()', 
		function(str)
			return HMathP.ProcessEquation(str:sub(2, -2));
		end);
	return HMathP.Calculate(frms);
end;

return HMathP;