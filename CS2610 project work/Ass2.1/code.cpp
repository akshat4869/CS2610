#include <cmath>
#include <cstdio>
#include <vector>
#include <iostream>
#include <algorithm>
using namespace std;

void makelps(string v,int*lps){
    int i=1,j=0; //assumed size of string >=2
    lps[j]=0;
    while(i<v.length()){
        if(v[i]==v[j]){
            lps[i]=j+1;
            i++;
            j++;
        }
        else{
            if(j!=0)
                j=lps[j-1];
            else{
                lps[i]=0;
                i++;
            }
        }
    }
}


void printresult(string x, string v, int* lps, int k){
    int i=0,j=0;
    int count=0;
    while(i<x.size()){
        if(x[i]==v[j]){
            i++;j++;
            
        }
        if(j == v.size()){
            count++;
            j=lps[j-1];
        }
        else if (x[i] != v[j]){
            if(j!=0){
                j  = lps[j-1];
            }
            else{
                i++;
            }     
        }
    }
    if(count >= k)
        cout<<"YES"<<endl;
    else
        cout<<"NO"<<endl;
    cout<<count<<endl;
}

string transform(string x, int l, int r, int s){
    for(int i=l; i<r+1; i++){
        int temp=x[i]+s;
        temp=temp%90;
        x[i]+=temp;
    }
    return x;
}

int main() {
    /* Enter your code here. Read input from STDIN. Print output to STDOUT */   
    int t;
    cin>>t;
    while(t--){
        string x,v;
        cin>>x>>v;
        int k;
        cin>>k;
        int lps[v.size()];
        makelps(v,lps);
        // for(int i=0;i<v.length();i++){
        //     cout<<lps[i]<<' ';
        // }
        // cout<<endl;
        printresult(x,v,lps,k);
        int q;
        cin>>q;
        while(q--){
            int l,r,s;
            cin>>l>>r>>s;
            x = transform(x,l,r,s);
        }
        printresult(x,v,lps,k);
    }
    return 0;
}
