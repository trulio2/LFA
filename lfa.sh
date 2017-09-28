#!/bin/bash
checkfinal()
{
echo $n
 for (( k = 0; k < ${#finals[@]}; k++ )); do
  if [[ ${atual[$pos]} == ${finals[$k]} ]]; then
    check="Sim"
   break
  fi
 done
 if [[ $k -eq ${#finals[@]} ]]; then
   check="Nao"
 fi
}

mover()
{
 for (( ; n < ${#grafo[@]}; n+=3  )); do
  if [[ ${atual[$pos]} -eq ${grafo[$n]} && (${teste[$j]} == ${grafo[$n+1]} || ${grafo[$n+1]} == '#') ]]; then
    if [[ ${grafo[$n+1]} == '#' ]]; then
	let j--
    fi
echo -n "${atual[$pos]} -> "
      let pos++
       atual[$pos]=${grafo[$n+2]}
echo  "${atual[$pos]}"

       break
  fi
 done
  if [[ $n -ge ${#grafo[@]} ]]; then
   let cont++
   let pos-=cont
   let n-=cont*3
  fi

}

if [[ $# == 0  ]]; then
	echo "Usar: $0 [AFNλ]"
	exit 1
fi
mudaestado=0
i=0
for arq in $(cat $1); do
 arq=$(echo $arq  | sed "s:\"::g" | sed "s:\}::g" | sed "s:\,::g")
 if [[ $mudaestado > 0 ]]; then
  est=$(echo "$est,$arq")
 fi
 if [[ $arq == '[' || $arq == ']' ]]; then
  estado=$(echo "$est")
  if [[ $mudaestado == 1 ]]; then
  estadosiniciais=$estado
  else
   grafo=$(echo $grafo$estado | sed "s:,: :g" | sed "s:\]::g" | sed "s:\[::g")
  fi

  est=''
  let mudaestado++
 fi

done
initials=$(echo "$estado" | sed "s:\[::g" | sed "s:\ ::g" | sed "s:,: :g" | awk -F"]" '{print $1}')
finals=$(echo "$estado" | sed "s:\[::g" | sed "s:\ ::g" | sed "s:,: :g" | awk -F"]" '{print $2}')

estados=$(echo "$estadosiniciais" | sed "s:\[::g" | sed "s:\ ::g" | sed "s:,: :g" | awk -F"]" '{print $1}')

transicoes=$(echo "$estadosiniciais" | sed "s:\[::g" | sed "s:\ ::g" | sed "s:,: :g" | awk -F"]" '{print $2}')

estados=(${estados})

for (( i = 0; i < ${#estados[@]}; i++ )); do
  grafo=$(echo $grafo | sed "s:${estados[$i]}:$i:g")
  initials=$(echo $initials | sed "s:${estados[$i]}:$i:g")
  finals=$(echo $finals | sed "s:${estados[$i]}:$i:g")
  estados[$i]=$i
done

finals=(${finals})
initials=(${initials})
transicoes=(${transicoes})
grafo=(${grafo})
declare -A matriz
for (( i=0; i<${#estados[@]}; i++  )); do
   for (( j=0; j<${#estados[@]}; j++ )); do
      matriz["$i","$j"]="-1"
   done
done

remover=$(echo "${#grafo[@]} - ${#finals[@]} - ${#initials[@]}" | bc -l)

for (( i = ${#grafo[@]}; i >= $remover; i-- )); do
    grafo[$i]=''
done
for (( i = 0; i < $remover; i+=3 )); do
  matriz[${grafo[$i]},${grafo[$i+2]}]=${grafo[$i+1]}
done

for (( i=0; i<${#estados[@]}; i++  )); do
   for (( j=0; j<${#estados[@]}; j++ )); do
     echo -n "${matriz[$i,$j]} "
   done
 echo
done


while true; do
 read teste
 teste=$(echo ${teste} | grep -o .)
 teste=(${teste})
 cont=1
 sub=$(echo "${#teste[@]} - 1" | bc -l)
 for init in ${initials[@]}; do
  check="Nao"
  pos=0
  n=0
  atual[$pos]=${initials[$init]}
  for (( j = 0; j < ${#teste[@]}; j++ )); do
   mover
   for (( i = 0; i < ${#transicoes[@]}; i++ )); do
     if [[ ${teste[$j]} == ${transicoes[$i]} ]]; then
      break
     fi
   done
   if [[ $i == ${#transicoes[@]} ]]; then
    echo "Não"
    break
   fi
    if  [[ $j -eq $sub ]]; then
     checkfinal
     if [[ $check == "Sim" ]]; then
      break
     fi
     let n+=cont*3
     let j-=cont
      if [[ $j -lt 0 ]]; then
      let j=-1
     fi
     let cont--
    fi
  done
 done
 echo $check
done

