#include <iostream>
#include <iomanip>
#include <fstream>
#include <thread>
#include <array>

using namespace std;
using namespace std::chrono;

array<uint64_t, 4> read_stuff()
{
	array<uint64_t,4> prev;
	string dummy;
	
	ifstream s("/proc/stat");
	s >> dummy;
	for(auto& r:prev)
		s >> r;
	return prev;
}

int main()
{
	double slow=0, slow_f = 0.05;
 	double fast=0, fast_f = 0.2;

	array<uint64_t,4> prev = read_stuff();
	std::this_thread::sleep_for(100ms);
	cout << "[30m"; // black text
	cout << "[?25l"; //Cursor off

	for(uint64_t i=0;;i++)
	{
		array<uint64_t, 4> current = read_stuff();
	
		uint64_t sum_all=0;
		uint64_t sum_not_idle=0;

		for(int i=0; i < 4; i++)
		{
			sum_all += current[i] - prev[i];
			if(i < 3)
				sum_not_idle += current[i] - prev[i];
		}

		prev = current;

		double load = sum_not_idle * 1.0 / sum_all;

		slow = load * slow_f + (1-slow_f) * slow;
		fast = load * fast_f + (1-fast_f) * fast;


		//Set the color
		int r, g;

		if(fast < 0.5)
		{	
			g=255;
			r = max(0., min(255., 255*2*fast));
		}	
		else
		{	
			r=255;
			g = max(0., min(255., (1-fast)*2*255));
		}
		
		cout << "]11;rgb:" << hex << setw(2) << setfill('0') <<r << "/" << g << dec << "/00\x7";
		if(i % 10 == 0)
		{
			cout << setw(5) << setfill(' ') << fixed << setprecision(1) << slow * 100;
			cout << "\b\b\b\b\b";
		}
		cout << flush;
		
		std::this_thread::sleep_for(100ms);
	}
	
}
