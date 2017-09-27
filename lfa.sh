#!/bin/bash
checkfinal()
{
 for (( k = 0; k < ${#estadosfinais[@]}; k++ )); do
  if [[ $atual == ${estadosfinais[$k]} ]]; then
   echo "Sim"
   break
  fi
 done
 if [[ $k -eq ${#estadosfinais[@]} ]]; then
   echo "Não"
 fi
}

mover()
{
 for (( n = 0; n < ${#grafo[@]}; n+=3  )); do
  if [[ $atual -eq ${grafo[$n]} && ${teste[$j]} == ${grafo[$n+1]} ]]; then
       atual=${grafo[$n+2]}
       break
  fi
 done
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

estadosiniciais=$(echo "$estado" | sed "s:\[::g" | sed "s:\ ::g" | sed "s:,: :g" | awk -F"]" '{print $1}')
estadosfinais=$(echo "$estado" | sed "s:\[::g" | sed "s:\ ::g" | sed "s:,: :g" | awk -F"]" '{print $2}')

estados=$(echo "$estadosiniciais" | sed "s:\[::g" | sed "s:\ ::g" | sed "s:,: :g" | awk -F"]" '{print $1}')

transicoes=$(echo "$estadosiniciais" | sed "s:\[::g" | sed "s:\ ::g" | sed "s:,: :g" | awk -F"]" '{print $2}')

estados=(${estados})

for (( i=0; i<${#estados[@]}; i++ )); do
  grafo=$(echo $grafo | sed "s:${estados[$i]}:$i:g")
  estadosfinais=$(echo $estadosfinais | sed "s:${estados[$i]}:$i:g")
  estados[$i]=$i
done

estadosfinais=(${estadosfinais})
estadosiniciais=(${estadosiniciais})
transicoes=(${transicoes})
grafo=(${grafo})
remover=$(echo "${#grafo[@]} - ${#estadosfinais[@]}" | bc -l)

for (( i = ${#grafo[@]}; i >= $remover; i-- )); do
    grafo[$i]=''
done

while true; do
 read teste
 atual=${estadosiniciais[0]}
 teste=$(echo ${teste} | grep -o .)
 teste=(${teste})

 for (( j = 0; j < ${#teste[@]}; j++ )); do
  mover
  if [[ $j -eq 0 && ${teste[0]} == '#' ]]; then
     if [[ ${#teste[@]} -gt 1 ]]; then
      echo "Não"
      break
     fi
     break
  fi
  for (( i = 0; i < ${#transicoes[@]}; i++ )); do
    if [[ ${teste[$j]} == ${transicoes[$i]} ]]; then
     break
    fi
  done
 if [[ $i == ${transicoes[@]} ]]; then
  echo "Não"
  break
 fi
 done
 checkfinal
done

