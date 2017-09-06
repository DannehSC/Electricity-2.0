git clone https://github.com/DannehSC/Electricity-2.0.git
rm -rf /bot
mv /Electricity-2.0 /bot
cp /luvit/luvit /bot
cp /luvit/luvi /bot
cp /luvit/lit /bot
cp /luvit/stuff.zip /bot
cd /bot
unzip stuff.zip
chmod a+x luvit
chmod a+x luvi
chmod a+x luv
rm -rf deps
git clone https://github.com/DannehSC/Electricity-2.0-Deps.git
mv Electricity-2.0-Deps deps
rm -rf /Electricity-2.0
./luvit Bot.lua