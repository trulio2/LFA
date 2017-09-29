#!/bin/bash
checkfinal(){
 for (( k = 0; k < ${#finals[@]}; k++ )); do
  if [[ ${atual[$1]} == ${finals[$k]} ]]; then
    check="Sim"
   break
  fi
 done
 if [[ $k -eq ${#finals[@]} ]]; then
   check="Nao"
 fi
}


if [[ $# -ne 1  ]]; then
	echo "Usar: $0 [AFNλ]" 1>&2
	exit 1
fi

mudaestado=0
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
      matriz["$i","$j"]=""
   done
done
remover=$(echo "${#grafo[@]} - ${#finals[@]} - ${#initials[@]}" | bc -l)
for (( i = ${#grafo[@]}; i >= $remover; i-- )); do
    grafo[$i]=''
done
for (( i = 0; i < $remover; i+=3 )); do
  matriz[${grafo[$i]},${grafo[$i+2]}]=$(echo "${matriz[${grafo[$i]},${grafo[$i+2]}]}${grafo[$i+1]}")
done

verificar(){
 if [[ $3 -ge ${#teste[@]} ]]; then
   let final=$1-1
   checkfinal $final
 else
  if [[ $check == "Nao" ]]; then
   if [[ ${teste[$3]} == '#' ]]; then
     let hash=$1-1
     checkfinal $hash
   fi
   local i=0
   for (( ; i < ${#estados[@]}; i++ )); do
     if [[ ${matriz[$2,$i]} == ${teste[$3]} || ${matriz[$2,$i]} == '#' ]]; then
       atual[$1]=$i
       let  inseridos=$1+1
       let  test=$3+1
       if [[ ${matriz[$2,$i]} == '#' ]]; then
        let test--
       fi
       verificar $inseridos $i $test
     fi
   done
  fi
 fi
}
while true; do
 read teste
 teste=$(echo ${teste} | grep -o .)
 teste=(${teste})
 for init in ${initials[@]}; do
   for (( n=0; n< ${#atual[@]}; n++ )); do
    atual[$n]=''
   done
   inseridos=1
   test=0
   check="Nao"
   atual[0]=${initials[$init]}
   verificar $inseridos ${atual[0]} $test
   if [[ $check == "Sim" ]]; then
      break
   fi
 done
  echo $check
done
