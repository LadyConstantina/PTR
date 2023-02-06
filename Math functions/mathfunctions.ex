defmodule MathFunctions do

#--------------isPrime(n)-----------------------------

    def isPrime(x) when is_integer(x) do
        try do
            if x == 1 or x == 2 or x == 3 do
                True
            else
                for n <- 2..div(x,2) do
                    if rem(x,n) == 0 do
                        throw(:break)
                    end
                end
                True
            end 
        catch
            :break -> False
        end
    end

#--------------cylinderArea(height,radius)------------

    def cylinderArea(h,r) do
        2 * :math.pi() * r * (h+r)
    end

#--------------reverse(list)--------------------------

    def reverse(list) do
        reversing(list,[])
    end

    defp reversing([],list2) do
        list2
    end

    defp reversing([head|tail],list2) do
        reversing(tail,[head|list2]) 
    end 

#--------------uniqueSum(list)------------------------

    def uniqueSum(list) do
        summing(list,0,length(list),0)
    end

    defp summing(_list,start,finish,sum) when start == finish do 
        sum
    end

    defp summing([head|tail],start, finish, sum) when start != finish do
        if head in tail do
            summing(tail ++ [head],start+1,finish,sum)
        else
            summing(tail ++ [head],start+1,finish,sum + head)
        end
    end

#--------------extractRandomN(list,n)-----------------

    def extractRandomN(_list,0) do 
        [] 
    end

    def extractRandomN(list,n) do
        response = Enum.random(list)
        [response] ++ extractRandomN(list -- [response],n - 1)
    end

#--------------firstFibonacciElements(n)--------------

    def firstFibonacciElements(1) do
        [1]
    end

    def firstFibonacciElements(n) do
        fibonacci(n-2,[1,1])
    end

    defp fibonacci(n,list) when n>0 do
        el1 = List.last(list)
        el2 = List.last(list -- [el1])
        fibonacci(n-1,list ++ [el1+el2])
    end

    defp fibonacci(n,list) when n<= 0 do
        list
    end

#--------------translator(dict,string)----------------

    def translator(dict,string) do
        Enum.join(swap(dict,string)," ")
    end

    defp swap(dict,string) do
        list = String.split(string, " ")
        for s <- list do
            HashDict.get(dict,String.to_atom(s),s)
        end
    end

    def translatortest() do
        d = Enum.into([mama: "mother",papa: "father"],HashDict.new())
        str = "mama is with papa"
        translator(d,str)
    end

#--------------smallestNumber(a,b,c)------------------

    def smallestNumber(0,0,0) do
        0
    end

    def smallestNumber(a,b,c) do
        list = Enum.sort([a,b,c])
        z = Enum.count(list,&(&1 == 0))
        cond do
            z==0 -> (Enum.at(list,0) * 100) + (Enum.at(list,1) * 10) + (Enum.at(list,2)) 
            z==1 -> (Enum.at(list,1) * 100) + (Enum.at(list,2)) 
            z==2 -> (List.last(list) * 100)
        end
    end

#--------------rotateLeft(list,n)---------------------

    def rotateLeft(list,0) do
        list
    end

    def rotateLeft([head|tail],n) do
        rotateLeft(tail ++ [head],n-1)
    end

#--------------listRightAngleTriangles()--------------

    def listRightAngleTriangles() do
        Enum.filter(trianglesCompute(), & !is_nil(&1))
    end

    defp cupleAngles() do
        for a <- 1..20, b <- 1..20 do
            [a,b]
        end
    end

    defp trianglesCompute() do
        list = cupleAngles()
        for [a,b] <- list do
            triangle(a,b)
        end
    end

    defp triangle(a,b) do
        c = :math.sqrt(a*a + b*b)
        if c - trunc(c) < 0.00001 do
            [a,b,trunc(c)]
        end
    end

#--------------removeConsecutiveDublicates(list)------

    def removeConsecutiveDublicates(list) do
        removeDub(list,length(list))
    end

    defp removeDub(list,0) do
        list
    end

    defp removeDub([head | tail],n) do
        if head === List.first(tail) do
            removeDub(tail, n-1)
        else
            removeDub(tail++[head], n-1)
        end
    end

#--------------lineWords(list)------------------------

    def lineWords(list) do
        Enum.filter(lineWordsCheck(list),& !is_nil(&1))
    end

    defp lineWordsCheck(list) do
        list2 = perfectStr(list)
        list3 = for str <- list2 do Enum.any?(checkAll(str)) end
        for i <- 0..length(list)-1 do
            if Enum.at(list3,i) do
                Enum.at(list,i)
            end
        end
    end

    defp perfectStr(list) do
        for str <- list do
            String.split(String.downcase(str),"")
        end
    end

    defp checkAll(str) do
        lines = [["q","w","e","r","t","y","u","i","o","p",""],["a","s","d","f","g","h","j","k","l",""],["z","x","c","v","b","n","m",""]]
        for line <- lines do
            Enum.all?(check(str,line),&(&1==True))
        end
    end

    defp check(str,line) do
        for let1 <- str do
            if let1 in line do
                True
            else
                False
            end
        end
    end

#--------------encode(str,key)------------------------

    def encode(str,key) do
        list = String.to_charlist(String.downcase(str))
        Enum.map(list,&(rem((&1 - ?a + key),26)+?a))
    end

#--------------decode(str,key)------------------------

    def decode(str,key) do
        list = String.to_charlist(String.downcase(str))
        Enum.map(list,&(rem((&1 - ?a - key),26)+?a))
    end

#--------------lettersCombination(str)----------------

    def lettersCombination(str) do
        dict = %{2 => 'abc', 3 => 'def', 4 => 'ghi', 5 => 'jkl', 6 => 'mno', 7 => 'pqrs', 8 => 'tuv', 9 => 'wxyz'}
        numbers = for let <- Enum.filter(String.split(str,""),&(&1!="")) do String.to_integer(let) end
        numbers2letters(numbers,dict,[''])
    end

    defp numbers2letters([],_dict,result) do
        result
    end

    defp numbers2letters([head|tail],dict,result) do
        combine = for list <- result, char <- dict[head] do list ++ [char] end
        numbers2letters(tail,dict,combine)
    end

#--------------groupAnagrams(list)--------------------

    def groupAnagrams(list) do
        resp = Map.new()
        grouping(list,resp)
    end

    defp grouping([],resp) do
        resp
    end

    defp grouping([head|tail],resp) do
        key = Enum.sort(String.to_charlist(head))
        values = Map.get(resp,key,[])
        values = if head in values do values else values ++[head] end
        grouping(tail,Map.put(resp,key,values))
    end

#--------------commonPrefix(list)---------------------

    def commonPrefix(list) do
        find(list,0)
    end

    defp find(list,n) do
        if Enum.all?(checkPrefix(list,String.slice(Enum.at(list,0),0,n)),&(&1 == True)) do
            find(list,n+1)
        else
            String.slice(Enum.at(list,0),0,n-1)
        end
    end

    defp checkPrefix(list,slice) do
        for words <- list do
            if String.starts_with?(words,slice) do
                True
            else
                False
            end
        end
    end

#--------------toRoman(str)---------------------------

    def toRoman(str) do
        number = String.to_integer(str)
        dict = %{1000 => "M", 900 => "CM", 500 => "D", 400 => "CD", 100 => "C", 90 => "XC", 50 => "L", 40 => "XL", 10 => "X", 9 => "IX", 5 => "V", 4 => "IV", 1 =>"I" }
        transform(number, "", dict)
    end

    defp transform(0,roman,_dict) do
        roman
    end

    defp transform(number,roman,dict) do
        key = Enum.find(Enum.sort(Map.keys(dict),&(&1>=&2)),fn n -> n <= number end)
        transform(number - key,roman <> dict[key],dict)
    end

#--------------factorize(number)----------------------

    def factorize(number) do
        factors(2,number,[])
    end

    defp factors(start,limit,result) when start > limit do
        result
    end

    defp factors(start,limit,result) when start <= limit do
        if isPrime(start) == True and rem(limit,start) == 0 do
            factors(start+1,limit,result ++ [start])
        else
            factors(start+1,limit,result)
        end
    end
end