#include <bits/stdc++.h>
using namespace std;

int main()
{
    string final[128];
    string s[16];
    for(int i=0;i<16;i++){
       cin>>s[i];
    }
   for(int i=0;i<16;i++){
        if(s[i].length()<16){
            int p=s[i].length();
            for(int j=0;j<16-p;j++){
                s[i]='0'+s[i];
            }
        }
        final[i]=s[i];
        final[i+16]=s[i];
        final[i+32]=s[i];
        final[i+48]=s[i];
        final[i+64]=s[i];
        final[i+80]=s[i];
        final[i+96]=s[i];
        final[i+112]=s[i];
   }
   for(int i=0;i<128;i++){
       cout<<final[i];
   }
   return 0;
}
