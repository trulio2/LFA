#!/bin/bash
if [[ $# -ne 1  ]]; then
	echo "Usar: $0 [AFNλ]" 1>&2
	exit 1
fi

mudaestado=0
for arq in $(cat $1); do
 arq=$(echo $arq  | tr -d \"},)
 [[ $mudaestado > 0 ]] && { est=$(echo "$est,$arq"); }
 if [[ $arq == '[' || $arq == ']' ]]; then
  estado=$(echo "$est")
  if [[ $mudaestado == 1 ]]; then
  estadosiniciais=$estado
  else
   grafo=$(echo $grafo$estado | tr , " " |tr -d [])
  fi
  est=''
  let mudaestado++
 fi
done
initials=$(echo "$estado" | tr -d [" " | tr , " "| awk -F"]" '{print $1}')
finals=$(echo "$estado" | tr -d [" " |tr , " "  | awk -F"]" '{print $2}')
estados=$(echo "$estadosiniciais" | tr -d [" " | tr , " "  | awk -F"]" '{print $1}')
transicoes=$(echo "$estadosiniciais" | tr -d [" " | tr , " " | awk -F"]" '{print $2}')

estados=(${estados})
for i in ${!estados[@]}; do
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
for i in ${!estados[@]}; do
   for j in ${!estados[@]}; do
      matriz[$i,$j]=""
   done
done
remover=$(echo "${#grafo[@]} - ${#finals[@]} - ${#initials[@]}" | bc -l)
for (( i = ${#grafo[@]}; i >= $remover; i-- )); do
    grafo[$i]=''
done
for (( i = 0; i < $remover; i+=3 )); do
  matriz[${grafo[$i]},${grafo[$i+2]}]=$(echo "${matriz[${grafo[$i]},${grafo[$i+2]}]}${grafo[$i+1]}")
done

checkfinal(){
 for (( k = 0; k < ${#finals[@]}; k++ )); do
  [[ ${atual[$1]} == ${finals[$k]} ]] && { check="Sim"; break; }
 done
 [[ $k -eq ${#finals[@]} ]] && { check="Nao"; }
}

verificar(){
 if [[ $3 -ge ${#teste[@]} ]]; then
   let final=$1-1
   checkfinal $final
 else
  if [[ $check == "Nao" ]]; then
   [[ ${teste[$3]} == '#' ]] && { let hash=$1-1; checkfinal $hash; }
   local i=0
   for i in ${!estados[@]}; do
     local conf=0
     valores=$( echo ${matriz[$2,$i]} | fold -w1)
     valores=(${valores})
     for val in ${valores[@]}; do
        [[ $val == ${teste[$3]} || $val == '#' ]] && { conf=1; break; }
        conf=0
     done
     if [[ $conf -eq 1 ]]; then
       atual[$1]=$i
       let inseridos=$1+1
       let test=$3+1
       [[ ${matriz[$2,$i]} == '#' ]] && { let test--; }
       verificar $inseridos $i $test
     fi
   done
  fi
 fi
}

while true; do
 read teste
 [[ $teste == '' ]] && { exit 0; }
 teste=$(echo ${teste} | grep -o .)
 teste=(${teste})
 for init in ${initials[@]}; do
   check="Nao"
   b=0; u=0
   for u in ${!teste[@]}; do
    [[ ${teste[$u]} == '#' && ${#teste[@]} -gt 1 ]] && { b=1 ; break; }
   done
   [[ $b == 1 ]] && { break; }
   for n in ${!atual[@]}; do
    atual[$n]=''
   done
   inseridos=1
   test=0
   atual[0]=${initials[$init]}
   verificar $inseridos ${atual[0]} $test
   [[ $check == "Sim" ]] && {  break; }
 done
  echo $check
done
