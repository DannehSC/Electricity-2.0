git clone https://github.com/DannehSC/Electricity-2.0.git
cd Electricity-2.0
git checkout deps
cd ..
mv Electricity-2.0 deps
curl -L https://github.com/luvit/lit/raw/master/get-lit.sh | sh
./luvit bot.lua
rm -Rf deps
rm luvit luvi lit
