#!/bin/bash
verificar(){
 test $1 -eq 1 || {
	echo "Usar: $0 [OPTION] AFNλ" 1>&2;
        echo "	-p,--path	Mostra os caminhos testados" ;
        echo "	-h,--help	Mostra esta mensagem";
	exit 1; }
}
args=
show=off
while [ $# != 0 ]; do
    case $1 in
    -h|--help) verificar 0 ;;
    -p|--path) show=on ;;
    -?*|-*) echo "Opção Desconhecida: $1" 1>&2; verificar 0 ;;
    *) args="$args $1" ;;
    esac
    shift
done
args=($args)
verificar ${#args[@]}
test -f $args || { echo "$args não é um arquivo regular" 1>&2; exit 2; }

mudaestado=0
for arq in $(cat $args); do
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
initials=$(echo "${estado//[}" | tr -d " " | tr , " "| awk -F"]" '{print $1}')
finals=$(echo "${estado//[}" | tr -d " " |tr , " "  | awk -F"]" '{print $2}')
estados=$(echo "${estadosiniciais//[}" | tr -d " " | tr , " "  | awk -F"]" '{print $1}')
transicoes=$(echo "${estadosiniciais//[}" | tr -d " " | tr , " " | awk -F"]" '{print $2}')

estados=(${estados})
finals=(${finals})
initials=(${initials})
transicoes=(${transicoes})
grafo=(${grafo})

declare -A matriz
remover=$(echo "${#grafo[@]} - ${#finals[@]} - ${#initials[@]}" | bc -l)
for (( i = ${#grafo[@]}; i >= $remover; i-- )); do
    unset grafo[$i]
done
for i in  ${!finals[@]}; do
   for j in ${!estados[@]}; do
      [[ ${finals[$i]} == ${estados[$j]} ]] && { finals[$i]=$j; break; }
   done
done
for i in ${!initials[@]}; do
   for j in ${!estados[@]}; do
      [[ ${initials[$i]} == ${estados[$j]} ]] && { initials[$i]=$j; break; }
   done
done
for (( i=0; i < ${#grafo[@]}; i+=3 )); do
  for j in ${!estados[@]}; do
      [[ ${grafo[$i]} == ${estados[$j]} ]] && { grafo[$i]=$j; break; }
  done
done
for (( i=2; i < ${#grafo[@]}; i+=3 )); do
  for j in ${!estados[@]}; do
      [[ ${grafo[$i]} == ${estados[$j]} ]] && { grafo[$i]=$j; break; }
  done
done
for (( i = 0; i < ${#grafo[@]}; i+=3 )); do
  matriz[${grafo[$i]},${grafo[$i+2]}]=$(echo "${matriz[${grafo[$i]},${grafo[$i+2]}]}${grafo[$i+1]}")
done
checkfinal(){
 local k=0
 for k in ${!finals[@]}; do
  [[ ${atual[$1]} == ${finals[$k]} ]] && { check="Sim"; break; }
 done
}

showpath(){
 local i
 for i in ${atual[@]}; do
  echo -n "${estados[$i]} "
 done
 echo
}

verificar(){
 local final=$1
 let final--
 if [[ $3 -ge ${#teste[@]} && $check == "Nao" ]]; then
   checkfinal $final
   test $show = on && showpath
 else
  if [[ $check == "Nao" ]]; then
   [[ ${teste[$3]} == '#' ]] && { checkfinal $final; test $show = on && showpath;  }
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
       unset atual[$1+1]
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
 [[ -z $teste ]] && { exit 0; }
 teste=$(echo ${teste} | grep -o .)
 teste=(${teste})
 for init in ${initials[@]}; do
   check="Nao"
   b=0
   for i in ${!teste[@]}; do
    for (( j = 0; j < ${#transicoes[@]}; j++ )); do
      [[ ${teste[$i]} == ${transicoes[$j]} || ${teste[$i]} == '#' ]]  &&  break
    done
    test  $j = ${#transicoes[@]} && { b=1; break; }
   done
   for u in ${teste[@]}; do
    [[ $u == '#' && ${#teste[@]} -gt 1 ]] && { b=1 ; break; }
   done
   test  $b = 1  && break
   for n in ${!atual[@]}; do
    unset atual[$n]
   done
   inseridos=1
   test=0
   atual[0]=$init
   verificar $inseridos ${atual[0]} $test
   [[ $check == "Sim" ]] && {  break; }
 done
  echo $check
done
